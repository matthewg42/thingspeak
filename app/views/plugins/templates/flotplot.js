<script type="text/javascript">
$(function() {
	// We use an inline data source in the example, usually data would
	// be fetched from a server

    // edit these 
    var base_url          = 'http://localhost:3000'; // no trailing / the url of your site!
    var plot_channel      = 1;
    var plot_field        = 'field1';
    var plot_color        = '#dd0000';
    var read_api_key      = '';
    var points_to_display = 50;
    var plot_options = {
        axisLabels: { show: true },
        xaxis: { mode: "time", axisLabel: "Date" },
        yaxis: { axisLabel: "Volts" },
    };

    // no edit from here
	var url = base_url + '/channels/' + plot_channel + '/field/1.json?offset=0' + (read_api_key.length ? '&api_key=' + read_api_key : '') + '&results=' + points_to_display;
    var last_displayed = 0;
    // No need to edit anything beyong this point!
    var buffer = [];
    $( document ).ready( setup );

    function fetcher() {
        console.log('fetcher()');
        $.getJSON(url + (last_displayed==0 && '' || '&start=' + (new Date(last_displayed+1000)).toISOString()), function(data) {
            $.each(data.feeds, function() {
                ts = getChartDate(this.created_at);
                val = parseFloat(this[plot_field]);
                buffer.push([ts, val]);
                console.log('got new record: ' + (new Date(ts)).toISOString() + ' : ' + val);
                if (ts > last_displayed) { last_displayed = ts; }
            });
            buffer = buffer.slice(0-points_to_display);
            display();
        });
        setTimeout(fetcher, 5000);
    }

    function getBuffer() {
        return buffer;
    }

    function display() {
        var plot = $.plot("#placeholder", [ {color: plot_color, data: getBuffer()} ], plot_options);
        plot.draw();
    }

    function setup() {
        // Call fetcher to get JSON and plot results (will re-call itself periodically)
        fetcher();
    }

    function getChartDate(d) {
        return Date.UTC(d.substring(0,4), 
                        d.substring(5,7)-1, 
                        d.substring(8,10), 
                        d.substring(11,13), 
                        d.substring(14,16), 
                        d.substring(17,19)) - ((new Date().getTimezoneOffset()) * 60000);
    }
});

</script>

