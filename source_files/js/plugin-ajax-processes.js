function testProcess() {
    var jsonData = saveToJson();
    var region = $('#drawing-plugin');
    console.log(region);

    var ajaxidentifier = region.data("ajax-identifier");
    console.log('ajaxidentifier: ' + ajaxidentifier);
    apex.server.plugin(
        ajaxidentifier,
        {
            x01: jsonData
        },
        {
            success: function (pData) {
                console.log(pData);
                apex.message.showPageSuccess('Drawing data saved to collection');
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.log(errorThrown);
            },
            dataType: 'json',
            async: true
        }
    );
}
