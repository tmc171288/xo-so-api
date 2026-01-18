const axios = require('axios');
const cheerio = require('cheerio');

async function analyze() {
    try {
        console.log('Fetching https://kqxs.vn/mien-nam ...');
        const res = await axios.get('https://kqxs.vn/mien-nam');
        const $ = cheerio.load(res.data);

        console.log('Tables found:');
        $('table').each((i, el) => {
            const className = $(el).attr('class');
            const id = $(el).attr('id');
            console.log(`Table ${i}: class="${className}", id="${id}"`);

            // Print first few rows to verify content
            const firstRow = $(el).find('tr').first().text().replace(/\s+/g, ' ').substring(0, 100);
            console.log(`  First row: ${firstRow}`);
        });

    } catch (error) {
        console.error('Error:', error.message);
    }
}

analyze();
