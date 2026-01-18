const axios = require('axios');
const cheerio = require('cheerio');

async function analyze() {
    try {
        const res = await axios.get('https://kqxs.vn/mien-nam');
        const $ = cheerio.load(res.data);

        // Find the first main result table
        const table = $('table.table-result, table.tbldata').first();

        if (table.length) {
            console.log('Result Table Found. Sample rows:');
            table.find('tr').slice(0, 5).each((i, tr) => {
                console.log(`Row ${i} HTML: ${$(tr).html().substring(0, 200)}...`);
            });

            // Check specific prize IDs or classes
            console.log('\nPrize checks:');
            console.log('Has .giai-dac-biet?', table.find('.giai-dac-biet').length);
            console.log('Has [id^="rs_"]?', table.find('[id^="rs_"]').length);
        } else {
            console.log('No result table found with standard classes.');
        }

    } catch (error) {
        console.log(error.message);
    }
}

analyze();
