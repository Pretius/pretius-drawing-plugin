var region = $('.drawing-plugin-body');
var ajaxidentifier = region.data("ajax-identifier");
//
var isFirstBatch = 1;
//
function sendToApex(data, isLastBatch) {
    return new Promise((resolve, reject) => {
        apex.server.plugin(
            ajaxidentifier,
            {
                x01: JSON.stringify(data),
                x02: isFirstBatch
            },
            {
                success: function (pData) {
                    console.log(pData);
                    if (isLastBatch) {
                        apex.message.showPageSuccess('Drawing data saved to collection');
                    }
                    isFirstBatch = 0;
                    resolve(pData);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log(errorThrown);
                    reject(errorThrown);
                },
                dataType: 'json',
                async: true
            }
        );
    });
}

async function testProcess() {
    var jsonData = saveToJson();
    
    var yourJSONObject = JSON.parse(jsonData);
    var i = 0;

    async function sendBatch() {
        console.log('Saving data');
        var jsonAgg = {};
        for (const key in yourJSONObject) {
            if (yourJSONObject.hasOwnProperty(key)) {
                const obj = yourJSONObject[key];
                jsonAgg[key] = obj;
                i++;
                if (i % 10 === 0 || i === Object.keys(yourJSONObject).length) {
                    await sendToApex(jsonAgg, i === Object.keys(yourJSONObject).length);
                    jsonAgg = {};
                    if (i === Object.keys(yourJSONObject).length) break;
                }
            }
        }
    }

    await sendBatch(); // Start the process
}
