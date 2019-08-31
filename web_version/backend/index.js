const express = require('express')
const app = express()
const port = process.env.PORT || 8080;

app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});


const http = require('http');
const https = require('https');

app.get('/test', (req, res, next) => res.send('test!'));

app.get('/auto-complete', function (req, resp, next) {
    let url = "http://api.geonames.org/postalCodeSearchJSON?username=scn3&country=US&maxRows=5&postalcode_startsWith=" + req.query.starts_with;
    http.get(url, (res) => {
        // const { statusCode } = res;
        // const contentType = res.headers['content-type'];
        //
        // let error;
        // if (statusCode !== 200) {
        //     error = new Error('Request Failed.\n' +
        //         `Status Code: ${statusCode}`);
        // } else if (!/^application\/json/.test(contentType)) {
        //     error = new Error('Invalid content-type.\n' +
        //         `Expected application/json but received ${contentType}`);
        // }
        // if (error) {
        //     console.error(error.message);
        //     res.resume;
        //     return;
        // }
        //
        // res.setEncoding('utf8');
        let rawData = '';
        res.on('data', (chunk) => {rawData += chunk;});
        res.on('end', () => {
           try {
               // const parsedData = JSON.parse(rawData);
               // console.log(parsedData);
               resp.send(rawData);
           } catch (e) {
               console.error(e.message);
           }
        });
    }).on('error', (e) => {
        consonle.error(`Got error: ${e.message}`);
    });
})

app.get('/search', function (req, resp, next) {
    let url = 'http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.0.0';
    url += '&SECURITY-APPNAME=WuweiCai-productS-PRD-616e2f5cf-6130b63e';
    url += '&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=50';
    url += '&keywords=' + encodeURI(req.query.keyword);
    url += '&buyerPostalCode=' + req.query.zipcode;
    let categoryMap = {
        'All Categories': '',
        'Art': '&categoryId=550',
        'Baby': '&categoryId=2984',
        'Books': '&categoryId=267',
        'Clothing, Shoes & Accessories': '&categoryId=11450',
        'Computers/Tablets & Networking': '&categoryId=58058',
        'Health & Beauty': '&categoryId=26395',
        'Music': '&categoryId=11233',
        'Video Games & Consoles': '&categoryId=1249'
    };
    url += categoryMap[req.query.category];
    url += '&itemFilter(0).name=MaxDistance&itemFilter(0).value=' + req.query.distance;
    url += '&itemFilter(1).name=HideDuplicateItems&itemFilter(1).value=true';
    let filterIdx = 2;
    if (req.query.shipping_options.indexOf('Free Shipping') != -1) {
        url += '&itemFilter(' + filterIdx + ').name=FreeShippingOnly&itemFilter(' + filterIdx + ').value=true';
        filterIdx += 1;
    }
    if (req.query.shipping_options.indexOf('Local Pickup') != -1) {
        url += '&itemFilter(' + filterIdx + ').name=LocalPickupOnly&itemFilter(' + filterIdx + ').value=true';
        filterIdx += 1;
    }
    if (req.query.condition.indexOf('All') == -1) {
        url += '&itemFilter(' + filterIdx + ').name=Condition';
        for (let i = 0; i < req.query.condition.length; i++) {
            url += '&itemFilter(' + filterIdx + ').value(' + i + ')=' + req.query.condition[i];
        }
    }
    url += '&outputSelector(0)=SellerInfo&outputSelector(1)=StoreInfo';

    http.get(url, (res) => {
        let rawData = '';
        res.on('data', (chunk) => {rawData += chunk;});
        res.on('end', () => {
            try {
                // const parsedData = JSON.parse(rawData);
                // console.log(parsedData);
                resp.send(rawData);
            } catch (e) {
                console.error(e.message);
            }
        });
    }).on('error', (e) => {
        consonle.error(`Got error: ${e.message}`);
    });
});

app.get('/detail', function (req, resp, next) {
    let url = "http://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON";
    url += "&appid=WuweiCai-productS-PRD-616e2f5cf-6130b63e&siteid=0&version=967";
    url += "&ItemID=" + req.query.itemId;
    url += "&IncludeSelector=Description,Details,ItemSpecifics";

    http.get(url, (res) => {
        let rawData = '';
        res.on('data', (chunk) => {rawData += chunk;});
        res.on('end', () => {
            try {
                resp.send(rawData);
            } catch (e) {
                console.error(e.message);
            }
        });
    }).on('error', (e) => {
        consonle.error(`Got error: ${e.message}`);
    });
});

app.get('/similar', function (req, resp, next) {
    let url = "http://svcs.ebay.com/MerchandisingService?OPERATION-NAME=getSimilarItems";
    url += "&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=1.1.0";
    url += "&CONSUMER-ID=WuweiCai-productS-PRD-616e2f5cf-6130b63e";
    url += "&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD";
    url += "&itemId=" + req.query.itemId + "&maxResults=20";

    http.get(url, (res) => {
        let rawData = '';
        res.on('data', (chunk) => {rawData += chunk;});
        res.on('end', () => {
            try {
                resp.send(rawData);
            } catch (e) {
                console.error(e.message);
            }
        });
    }).on('error', (e) => {
        consonle.error(`Got error: ${e.message}`);
    });
});

app.get('/photos', function (req, resp, next) {
    let url = 'https://www.googleapis.com/customsearch/v1?';
    url += '&q=' + encodeURIComponent(req.query.productTitle);
    url += '&cx=002545610802975014667:un-w33gsala';
    url += '&imageSize=huge&imageType=news&num=8&searchType=image';
    url += '&key=AIzaSyAHy6oTjjXeWQucZEOlrz4kDFkKf_B6BKQ';

    https.get(url, (res) => {
        let rawData = '';
        res.on('data', (chunk) => {rawData += chunk;});
        res.on('end', () => {
            try {
                resp.send(rawData);
            } catch (e) {
                console.error(e.message);
            }
        });
    }).on('error', (e) => {
        consonle.error(`Got error: ${e.message}`);
    });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`))