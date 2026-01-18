const axios = require('axios');
const cheerio = require('cheerio');
const CrawlLog = require('../models/CrawlLog');

class BaseCrawler {
    constructor(sourceName) {
        this.sourceName = sourceName;
    }

    async fetchHtml(url) {
        try {
            const response = await axios.get(url, {
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                },
                timeout: 10000
            });
            return cheerio.load(response.data);
        } catch (error) {
            console.error(`Error fetching ${url}:`, error.message);
            throw error;
        }
    }

    async logCrawl(status, region, message, records = 0, startTime) {
        const duration = Date.now() - startTime;
        try {
            await CrawlLog.create({
                status,
                region,
                message,
                recordsProcessed: records,
                durationMs: duration
            });
        } catch (error) {
            console.error('Error saving crawl log:', error.message);
        }
    }

    formatDate(dateObj) {
        // Format Date object to YYYY-MM-DD
        return dateObj.toISOString().split('T')[0];
    }
}

module.exports = BaseCrawler;
