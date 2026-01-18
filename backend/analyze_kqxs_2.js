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
            const rowCount = $(el).find('tr').length;
            console.log(`Table ${i}: class="${className}", id="${id}", rows=${rowCount}`);

            // Check if it looks like a result table
            if (className && className.includes('table-result')) {
                console.log('  -> POTENTIAL RESULT TABLE');
            }
        });

    } catch (error) {
        console.error('Error:', error.message);
    }
}

analyze();
