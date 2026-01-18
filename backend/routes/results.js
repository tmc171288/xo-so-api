const express = require('express');
const router = express.Router();
const LotteryResult = require('../models/LotteryResult');
const crawlerService = require('../services/CrawlerService');

// GET /api/results/:region/latest
router.get('/:region/latest', async (req, res) => {
    try {
        const { region } = req.params;
        const result = await LotteryResult.findOne({ region })
            .sort({ date: -1 })
            .lean(); // Faster query

        if (!result) return res.status(404).json({ message: 'No results found' });
        res.json(result);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/results/:region/history?page=1&limit=30
router.get('/:region/history', async (req, res) => {
    try {
        const { region } = req.params;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 30;
        const skip = (page - 1) * limit;

        const results = await LotteryResult.find({ region })
            .sort({ date: -1 })
            .skip(skip)
            .limit(limit)
            .lean();

        const total = await LotteryResult.countDocuments({ region });

        res.json({
            data: results,
            meta: {
                current_page: page,
                per_page: limit,
                total: total,
                total_pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/results/:region/:date (YYYY-MM-DD)
router.get('/:region/:date', async (req, res) => {
    try {
        const { region, date } = req.params;
        const results = await LotteryResult.find({
            region,
            date: { $regex: new RegExp(`^${date}`) } // Flexible match
        }).lean();

        res.json(results);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// POST /api/admin/crawl (Protected by simple key technically but open for demo)
router.post('/admin/crawl', async (req, res) => {
    try {
        // In production, check for API Key or Auth
        const { type = 'daily', days = 30 } = req.body;

        if (type === 'daily') {
            const results = await crawlerService.crawlDaily();
            return res.json({ message: 'Daily crawl started', count: results.length });
        } else if (type === 'history') {
            // Run in background to avoid timeout
            crawlerService.crawlHistory(days).catch(console.error);
            return res.json({ message: `Historical crawl for ${days} days started in background` });
        }

        res.status(400).json({ message: 'Invalid crawl type' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
