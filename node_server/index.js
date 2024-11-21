const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const app = express();
const PORT = 3000;

// JSON 형식의 요청 바디를 파싱하도록 설정
app.use(bodyParser.json());

app.post('/model', (req, res) => {
    const { userId, outfitName, top, bottom } = req.body;
    
    // Detailed logging of all received data
    console.log('\n=== Received Outfit Data ===');
    console.log('User ID:', userId);
    console.log('Outfit Name:', outfitName);
    
    console.log('\nTop Item Details:');
    console.log('- Image URL:', top.imageUrl);
    
    console.log('\nBottom Item Details:');
    console.log('- Image URL:', bottom.imageUrl);
    
    console.log('\nComplete Request Body:');
    console.log(JSON.stringify(req.body, null, 2));
    console.log('========================\n');

    // 5초 후 Python 스크립트 실행
    setTimeout(() => {
        // Python 스크립트 실행
        exec(`python3 upload_video_to_firebase.py ${userId}`, (err, stdout, stderr) => {
            if (err) {
                console.error(`exec error: ${err}`);
                return;
            }
            if (stderr) {
                console.error(`stderr: ${stderr}`);
                return;
            }
            console.log(`stdout: ${stdout}`);
        });
    }, 5000); // 5초 후에 실행

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
