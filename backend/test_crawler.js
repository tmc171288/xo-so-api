const mongoose = require('mongoose');
const MinhNgocCrawler = require('./crawlers/MinhNgocCrawler');
require('dotenv').config();

async function test() {
    // Mock DB connection or just parse
    console.log('Testing MinhNgocCrawler...');
    const crawler = new MinhNgocCrawler();

    // Patch fetchHtml to just log and return if we don't want to hit real DB
    // But we want to test parsing, so we need real HTML.
    // We will bypass DB saving in this test or mock the model.

    // Mock LotteryResult model to avoid DB errors
    const mockModel = {
        findOneAndUpdate: async (q, data, opts) => {
            console.log(`[MOCK DB] Saving ${data.province}: Special Prize = ${data.prizes.special}`);
            return data;
        }
    };

    // Inject mock (requires modifying Crawler to accept model or mocking require)
    // For simplicity, we just run and let it fail on DB but print logs before that
    // OR we comment out DB part in crawler... 
    // Actually, I'll just override the save logic in the instance for testing

    crawler.logCrawl = async (s, r, m) => console.log(`[LOG] ${s} - ${r}: ${m}`);

    // Override crawlRegion to NOT save to real DB but use mock
    const originalCrawl = crawler.crawlRegion.bind(crawler);
    crawler.crawlRegion = async (region) => {
        console.log(`Crawling ${region}...`);
        // We can't easy override the internal DB call without DI.
        // So let's just connect to a test DB or just handle the error.
        // Better: Connect to the docker mongo? No, user might not have it running yet.

        try {
            const $ = await crawler.fetchHtml(crawler.getRegionUrl(region));
            let results = [];
            if (region === 'north') results.push(crawler.parseNorth($));
            else results = crawler.parseMultiProvince($, region);

            console.log(`Fetched ${results.length} results for ${region}`);
            results.forEach(r => {
                if (r) console.log(`- ${r.province}: Special: ${r.prizes.special}`);
            });
        } catch (e) {
            console.error(e);
        }
    };

    crawler.getRegionUrl = (region) => {
        if (region === 'north') return 'https://www.minhngoc.net.vn/xo-so-mien-bac.html';
        if (region === 'central') return 'https://www.minhngoc.net.vn/xo-so-mien-trung.html';
        if (region === 'south') return 'https://www.minhngoc.net.vn/xo-so-mien-nam.html';
    };

    await crawler.crawlRegion('north');
    await crawler.crawlRegion('south');
}

test();
