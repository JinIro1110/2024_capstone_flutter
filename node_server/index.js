const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const PORT = 3000;

// JSON 형식의 요청 바디를 파싱하도록 설정
app.use(bodyParser.json());

app.post('/preference', (req, res) => {
    const { userId, styles, patterns, purposes, colors } = req.body;
    console.log('Received Data:');
    console.log('User ID:', userId);
    console.log('Styles:', styles);
    console.log('Patterns:', patterns);
    console.log('Purposes:', purposes);
    console.log('Colors:', colors);
    res.status(200).send('Data received successfully');
});

app.post('/model', (req, res) => {
    const { userId, outfitName, top, bottom } = req.body;
    
    // Detailed logging of all received data
    console.log('\n=== Received Outfit Data ===');
    console.log('User ID:', userId);
    console.log('Outfit Name:', outfitName);
    
    console.log('\nTop Item Details:');
    console.log('- Image URL:', top.imageUrl);
    console.log('- Style:', top.style);
    console.log('- Size:', top.size);
    
    console.log('\nBottom Item Details:');
    console.log('- Image URL:', bottom.imageUrl);
    console.log('- Style:', bottom.style);
    console.log('- Size:', bottom.size);
    
    console.log('\nComplete Request Body:');
    console.log(JSON.stringify(req.body, null, 2));
    console.log('========================\n');

    res.status(200).json({ 
        message: 'Data received successfully',
        receivedData: {
            userId,
            outfitName,
            top,
            bottom
        }
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});