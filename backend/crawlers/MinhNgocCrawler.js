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
        // Dynamic table class based on region
        let tableClass = 'bkqmiennam';
        if (region === 'central') tableClass = 'bkqmientrung';

        let table = $(`.box_kqxs .content table.${tableClass}`);

        // Fallback: If not found, look for any table containing "Giải tám" inside .content
        if (!table.length) {
            console.log(`Specific table .${tableClass} not found. Trying fallback search...`);
            $('.content table').each((i, el) => {
                if ($(el).text().includes('Giải tám') || $(el).text().includes('TP.HCM')) {
                    table = $(el);
                    console.log('Fallback table found!');
                    return false; // Break loop
                }
            });
        }

        if (!table.length) {
            console.log(`Table not found for ${region}`);
            return [];
        }

        let headers = table.find('thead tr th');
        // Fallback: Check first row of body if thead is empty
        if (!headers.length) {
            headers = table.find('tr').first().find('td, th');
            // Check if this row looks like a header (contains province names)
            // Or usually row 0 is date/title, row 1 is provinces.
            // Let's inspect rows more carefully.

            // Logic: Iterate first few rows to find one with > 1 columns and textual content
            if (headers.length < 2) {
                table.find('tr').each((i, row) => {
                    const cells = $(row).find('td, th');
                    if (cells.length > 1) { // Likely header row
                        // Check content. Province names usually don't start with digits.
                        const firstText = $(cells[0]).text().trim();
                        if (!firstText.match(/^\d/) && !firstText.includes('Giải')) {
                            headers = cells;
                            return false; // Found
                        }
                    }
                });
            }
        }

        const provinces = [];

        headers.each((i, el) => {
            const name = $(el).text().trim();
            // Provinces usually not named "Giải..." and not empty
            // Some layout has "Tỉnh" as first col.
            if (name && !name.includes('Giải') && name.length > 2 && !name.includes('Mã')) {
                provinces.push({ name, index: i });
            }
        });

        // Log found provinces for debugging
        console.log(`Found provinces for ${region}: ${provinces.map(p => p.name).join(', ')}`);

        // If no provinces found, legacy single-col parsing? 
        // MinhNgoc consistently has headers.

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

        // Robust row mapping via Classes OR Keywords
        // Map of keywords to keys
        const keywordMap = {
            'Giải tám': 'eighth', 'Giải bảy': 'seventh', 'Giải sáu': 'sixth',
            'Giải năm': 'fifth', 'Giải tư': 'fourth', 'Giải ba': 'third',
            'Giải nhì': 'second', 'Giải nhất': 'first', 'Giải đặc biệt': 'special'
        };

        table.find('tr').each((i, tr) => {
            // Skip rows that contain nested tables to avoid duplication/mess
            if ($(tr).find('table').length > 0) return;

            const firstCell = $(tr).children('td').first().text().trim();

            // Determine prize key from first cell text
            let prizeKey = null;
            for (const [key, value] of Object.entries(keywordMap)) {
                if (firstCell.includes(key) || $(tr).attr('class')?.includes(`giai${value === 'special' ? '_dacbiet' : key.replace('Giải ', '')}`)) {
                    prizeKey = value;
                    break;
                }
            }

            // Custom check specifically for G8 if text logic fails
            if (!prizeKey && $(tr).hasClass('giai8')) prizeKey = 'eighth';
            if (!prizeKey && $(tr).hasClass('giai_dacbiet')) prizeKey = 'special';

            if (prizeKey) {
                $(tr).children('td').each((j, td) => {
                    // The first td is Label (index 0). 
                    // Provinces start from index 1.
                    // j=1 maps to provinces[0], j=2 maps to provinces[1]...

                    if (j > 0 && j <= provinces.length) {
                        const provIndex = j - 1;
                        const text = $(td).text().trim();
                        // Split numbers by hyphens (simple format) or spaces, but prevent merging separate numbers
                        // MinhNgoc: "73" or "73 - 12"
                        const numbers = text.replace(/[-]/g, ' ').split(/\s+/).filter(x => x && x.match(/^\d+$/));

                        if (prizeKey === 'special') {
                            results[provIndex].prizes.special = numbers[0] || text;
                        } else {
                            results[provIndex].prizes[prizeKey].push(...numbers);
                        }
                    }
                });
            }
        });

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
