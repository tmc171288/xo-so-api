const MinhNgocCrawler = require('../crawlers/MinhNgocCrawler');
const LotteryResult = require('../models/LotteryResult');

class CrawlerService {
    constructor() {
        this.crawler = new MinhNgocCrawler();
    }

    async crawlDaily() {
        console.log('Starting daily crawl...');
        const regions = ['north', 'central', 'south'];
        const results = [];

        for (const region of regions) {
            console.log(`Crawling region: ${region}`);
            const regionResults = await this.crawler.crawlRegion(region);
            results.push(...regionResults);
        }

        return results;
    }

    async crawlHistory(days = 30) {
        console.log(`Starting historical crawl for ${days} days...`);
        const today = new Date();
        const regions = ['north', 'central', 'south'];

        for (let i = 0; i < days; i++) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];

            console.log(`Crawling date: ${dateStr}`);

            for (const region of regions) {
                // Check if already exists to avoid redundant crawls (optional optimization)
                const exists = await LotteryResult.findOne({ region, date: dateStr });
                if (exists && exists.prizes.special) {
                    // console.log(`Skipping ${region} ${dateStr} - already exists`);
                    continue;
                }

                await this.crawler.crawlRegion(region, date);
                // Respect rate limits, pause slightly
                await new Promise(r => setTimeout(r, 1000));
            }
        }
        console.log('Historical crawl completed.');
    }
}

module.exports = new CrawlerService();
