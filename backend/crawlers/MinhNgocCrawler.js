const BaseCrawler = require('./BaseCrawler');
const LotteryResult = require('../models/LotteryResult');

class MinhNgocCrawler extends BaseCrawler {
    constructor() {
        super('minhngoc.net.vn');
        this.baseUrl = 'https://www.minhngoc.net.vn';
    }

    async crawlRegion(region, date = null) {
        const startTime = Date.now();
        try {
            let url;
            const dateStr = date ? this.formatDateForUrl(date) : '';

            // Constructs URL based on region and optional date
            // MinhNgoc format: /xo-so-mien-bac/ngay-dd-mm-yyyy.html
            // Or /xo-so-mien-bac.html for today

            if (date) {
                if (region === 'north') url = `${this.baseUrl}/xo-so-mien-bac/${dateStr}.html`;
                else if (region === 'central') url = `${this.baseUrl}/xo-so-mien-trung/${dateStr}.html`;
                else if (region === 'south') url = `${this.baseUrl}/xo-so-mien-nam/${dateStr}.html`;
            } else {
                if (region === 'north') url = `${this.baseUrl}/xo-so-mien-bac.html`;
                else if (region === 'central') url = `${this.baseUrl}/xo-so-mien-trung.html`;
                else if (region === 'south') url = `${this.baseUrl}/xo-so-mien-nam.html`;
            }

            console.log(`Fetching ${url}...`);
            const $ = await this.fetchHtml(url);
            const results = [];

            if (region === 'north') {
                const result = this.parseNorth($);
                if (result) results.push(result);
            } else {
                const parsedResults = this.parseMultiProvince($, region);
                results.push(...parsedResults);
            }

            // Save to DB
            let savedCount = 0;
            for (const res of results) {
                await LotteryResult.findOneAndUpdate(
                    { region: res.region, province: res.province, date: res.date },
                    res,
                    { upsert: true, new: true }
                );
                savedCount++;
            }

            console.log(`Crawled ${savedCount} results for ${region}`);
            await this.logCrawl('success', region, 'Crawled successfully', savedCount, startTime);
            return results;

        } catch (error) {
            console.error(`Crawl failed for ${region}:`, error);
            await this.logCrawl('failed', region, error.message, 0, startTime);
            return [];
        }
    }

    parseNorth($) {
        const table = $('.box_kqxs .content table.bkqmienbac');
        if (!table.length) return null;

        // Date parsing: "Thứ ... ngày dd/mm/yyyy"
        const dateText = $('.box_kqxs .title').text() || '';
        const dateMatch = dateText.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
        let dateStr = new Date().toISOString().split('T')[0];
        if (dateMatch) {
            dateStr = `${dateMatch[3]}-${dateMatch[2].padStart(2, '0')}-${dateMatch[1].padStart(2, '0')}`;
        }

        const getPrizes = (selector) => {
            const text = table.find(selector).text().trim();
            return text ? text.split(/\s-\s|\s+/).filter(x => x) : [];
        };

        return {
            region: 'north',
            province: 'Hà Nội', // MB chung
            date: dateStr,
            prizes: {
                special: table.find('.giai_dacbiet').text().trim(),
                first: getPrizes('.giai_nhat'),
                second: getPrizes('.giai_nhi'),
                third: getPrizes('.giai_ba'),
                fourth: getPrizes('.giai_tu'),
                fifth: getPrizes('.giai_nam'),
                sixth: getPrizes('.giai_sau'),
                seventh: getPrizes('.giai_bay'),
            },
            isLive: false // Todo: Logic for live detection
        };
    }

    parseMultiProvince($, region) {
        const results = [];
        const table = $('.box_kqxs .content table.bkqmiennam'); // MN and MT use similar structure often labeled miennam or distinct
        // MinhNgoc logic for MT/MN is complex: multiple columns for provinces.

        // Handling the multi-column layout is tricky blindly. 
        // Strategy: iterate headers to find provinces, then mapping rows to column indices.

        const headers = table.find('thead tr th');
        const provinces = [];

        headers.each((i, el) => {
            const name = $(el).text().trim();
            if (name && !name.includes('Giải')) {
                provinces.push({ name, index: i });
            }
        });

        // Current date from title
        const dateText = $('.box_kqxs .title').text() || '';
        const dateMatch = dateText.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
        let dateStr = new Date().toISOString().split('T')[0];
        if (dateMatch) {
            dateStr = `${dateMatch[3]}-${dateMatch[2].padStart(2, '0')}-${dateMatch[1].padStart(2, '0')}`;
        }

        provinces.forEach(p => {
            results.push({
                region,
                province: p.name,
                date: dateStr,
                prizes: {
                    eighth: [], seventh: [], sixth: [], fifth: [],
                    fourth: [], third: [], second: [], first: [], special: ''
                }
            });
        });

        // Rows mapping (approximate, needs verifying with real HTML)
        // Usually: G8, G7, G6... Special
        // Rows have classes like 'giai8', 'giai7'

        const mapRow = (className, prizeKey) => {
            table.find(`tr.${className}`).each((i, tr) => {
                // The first td is the specific prize label, subsequent tds are results
                // But MinhNgoc layout might have provinces as columns.
                // Let's assume standard multi-col: 
                // Col 0: Label
                // Col 1: Prov 1
                // Col 2: Prov 2...

                $(tr).find('td').each((j, td) => {
                    // Check if this td corresponds to a province column
                    // The index of td might need offset info if not aligned perfectly.
                    // Often label is one td.

                    // Helper: Find which province this td belongs to.
                    // Simplified: assume td index 1 maps to province index 0

                    if (j > 0 && j <= provinces.length) {
                        const provIndex = j - 1;
                        const text = $(td).text().trim();
                        const numbers = text.split(/\s+/).filter(x => x);

                        if (prizeKey === 'special') results[provIndex].prizes.special = text;
                        else results[provIndex].prizes[prizeKey].push(...numbers);
                    }
                });
            });
        };

        mapRow('giai8', 'eighth');
        mapRow('giai7', 'seventh');
        mapRow('giai6', 'sixth');
        mapRow('giai5', 'fifth');
        mapRow('giai4', 'fourth');
        mapRow('giai3', 'third');
        mapRow('giai2', 'second');
        mapRow('giai1', 'first');
        mapRow('giai_dacbiet', 'special');

        return results;
    }

    formatDateForUrl(date) {
        // Input: Date object or string YYYY-MM-DD
        // Output: ngay-dd-mm-yyyy
        const d = new Date(date);
        const day = d.getDate().toString().padStart(2, '0');
        const month = (d.getMonth() + 1).toString().padStart(2, '0');
        const year = d.getFullYear();
        return `ngay-${day}-${month}-${year}`;
    }
}

module.exports = MinhNgocCrawler;
