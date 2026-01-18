const axios = require('axios');
const cheerio = require('cheerio');

async function debugNesting() {
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

        console.log('Total tr via find("tr"):', table.find('tr').length);
        console.log('Direct children tr (via > tbody > tr):', table.children('tbody').children('tr').length);
        console.log('Direct children tr (via > tr):', table.children('tr').length);

        // Check if rows have nested tables
        let nestedCount = 0;
        table.find('tr').each((i, tr) => {
            if ($(tr).find('table').length > 0) {
                nestedCount++;
                console.log(`Row ${i} contains a nested table!`);
            }
        });
        console.log('Rows with nested tables:', nestedCount);

    } catch (e) {
        console.error(e);
    }
}

debugNesting();
