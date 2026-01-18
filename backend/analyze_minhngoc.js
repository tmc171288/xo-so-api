const axios = require('axios');
const cheerio = require('cheerio');

async function analyze() {
    try {
        console.log('Fetching https://www.minhngoc.net.vn/xo-so-mien-nam.html ...');
        const res = await axios.get('https://www.minhngoc.net.vn/xo-so-mien-nam.html');
        const $ = cheerio.load(res.data);

        console.log('Tables found in .content:');
        $('.content table').each((i, el) => {
            const className = $(el).attr('class');
            const id = $(el).attr('id');
            console.log(`Table ${i}: class="${className}", id="${id}"`);
        });

        console.log('\nChecking for bkqmiennam:');
        console.log('Count:', $('.bkqmiennam').length);

    } catch (error) {
        console.error('Error:', error.message);
    }
}

analyze();
