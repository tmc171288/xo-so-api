const cron = require('node-cron');
const crawlerService = require('../services/CrawlerService');

// Schedule tasks to be run on the server
const initScheduledJobs = (io) => {
    // Crawl daily at 18:30, 18:35, 18:40, 19:00 (Vietnam Time)
    // Server time might be UTC, so we need to adjust or use timezone
    // 18:30 VN = 11:30 UTC

    const schedule = process.env.CRAWL_SCHEDULE || '30 11 * * *';

    console.log(`Initializing scheduled jobs with schedule: ${schedule} (UTC)`);

    cron.schedule(schedule, async () => {
        console.log('Running scheduled daily crawl...');
        try {
            const results = await crawlerService.crawlDaily();

            // Broadcast updates to all connected clients
            if (io) {
                results.forEach(result => {
                    io.emit('lottery_update', result);
                });
                console.log(`Broadcasted ${results.length} updates`);
            }
        } catch (error) {
            console.error('Scheduled crawl failed:', error);
        }
    });

    // Cleanup old data daily at 02:00 VN (19:00 UTC previous day)
    cron.schedule('0 19 * * *', async () => {
        // Handled by MongoDB TTL, but can add extra logic here if needed
        console.log('Daily cleanup check...');
    });
};

module.exports = initScheduledJobs;
