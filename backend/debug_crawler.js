const axios = require('axios');
const cheerio = require('cheerio');

async function debugValues() {
    const url = 'https://www.minhngoc.net.vn/xo-so-mien-nam.html';
    console.log(`Fetching ${url}...`);

    try {
        const res = await axios.get(url, {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
        });
        const $ = cheerio.load(res.data);

        const table = $('.bkqmiennam');
        console.log('Table .bkqmiennam found?', table.length > 0);

        if (table.length) {
            const thead = table.find('thead');
            console.log('thead found?', thead.length > 0);

            const headers = table.find('thead tr th');
            console.log('Header TH count:', headers.length);

            headers.each((i, el) => {
                console.log(`  Header ${i}: "${$(el).text().trim()}"`);
            });

            const rows = table.find('tr');
            console.log('Total rows:', rows.length);

            // Check first row cells
            const firstRow = rows.eq(1); // skip header
            console.log('Sample Row 1 cells:', firstRow.find('td').map((i, el) => $(el).text().trim()).get().join(' | '));
        } else {
            console.log('trying fallback search...');
            // Dump first 500 chars of content to see what's there
            console.log('Content snippet:', $('.content').text().substring(0, 500).replace(/\s+/g, ' '));
        }

    } catch (e) {
        console.error(e);
    }
}

debugValues();
