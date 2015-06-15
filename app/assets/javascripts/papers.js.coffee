# Sketches: sketch id + boolean if the sketch has loaded yet
sketches = {
	"paragraphs",
	"words": 0, 
	"average": 0, 
	"distinct": 0, 
	"oxford": 0,
	"fancy": 0,
	"awl": 0,
	"awl-details": 0,
	"word-cloud": 0
}

update_interval = 20000;

totalWordsLevels = [100, 1000, 2000, 3000, 4000, 5000, 10000, 15000, 20000 ];
totalWordsIdentifier = "num_words";

distinctLevels = [50, 100, 200, 300, 500, 800, 1000, 1250, 1500];
distinctIdentifier = "different_words";

paper_etag = undefined
chart = undefined

@updateSketches = (id) ->
        $.ajax "#{id.toString()}.json",
                type: 'GET'
                dataType: 'json'
                error: (jqXHR, textStatus, errorThrown) ->
                        console.log "WARNING: Couldn't get current stats"
                success: (data, textStatus, jqXHR) ->
                        if paper_etag != jqXHR.getResponseHeader("Etag")
                                console.log "SUCCESS: Got current stats, updating sketches..."
                                for sketch of sketches
                                        updateSketch(sketch, data)

                                if chart
                                        updateTimeline(data["history"])
                                else
                                        initTimeline(data["history"])
                                updateAchievements(data["achieved"])
                                paper_etag = jqXHR.getResponseHeader("Etag")


@updateSketch = (sketch, data) ->
        # Sketches aren't loaded when document is ready
        # --> wait for them to load, since Processing.js provides no callback
        timer = 0
        timeout = 2000
        clearInterval(mem)
        mem = setInterval ->
                instance = Processing.getInstanceById(sketch);
                if instance
                        if not sketches[sketch]
                                # Load this sketch for the first time
                                initSketch(sketch, instance)
                        instance.update(data["stats"]);
                        clearInterval(mem);
                else
                        timer += 10
                        if timer > timeout
                                console.log("WARNING: Failed to load sketch");
                                clearInterval(mem);
        , 10


@initSketch = (sketch, instance) ->
	switch sketch
		when "words"
			instance.setIdentifier(totalWordsIdentifier);
			instance.setLevels(totalWordsLevels);
		when "distinct"
			instance.setIdentifier(distinctIdentifier);
			instance.setLevels(distinctLevels);
		else # Do nothing

        sketches[sketch] = 1

time_line_data = undefined

@updateTimeline = (data) ->
        if time_line_data and data.length == time_line_data.length
                return
        time_line_data = data

        words = []
        pages = []

        $.each data, (key,value) ->
                words.push([Date.parse(value.time), value.words])
                pages.push([Date.parse(value.time), value.pages])

        chart.series[0].update
                data: words
                redraw: false
        chart.series[1].update
                data: pages
                redraw: false
        chart.redraw()

@initTimeline = (data) ->
        words = []
        pages = []

        $.each data, (key,value) ->
                words.push([Date.parse(value.time), value.words])
                pages.push([Date.parse(value.time), value.pages])

        $('#timeline').highcharts
                chart:
                        type: 'spline'
                        zoomType: 'x'
                        backgroundColor:'black'
                title: text: ''
                xAxis:
                        type: 'datetime'
                        dateTimeLabelFormats:
                                month: '%e. %b'
                                year: '%Y'
                        title: text: 'Date'
                yAxis: [
                        {
                                title: text: 'Words'
                                min: 0
                        }
                        {
                                title: text: 'Pages'
                                min: 0
                        }
                ]
                tooltip:
                        headerFormat: '<b>{series.name}</b><br>'
                        pointFormat: '{point.x:%e. %b}: {point.y}'
                plotOptions: spline: marker: enabled: false
                series: [
                        {
                                name: 'Words'
                                data: words
                                yAxis: 0
                                zoneAxis: 'x'
                                zones: [
                                        { value: words[words.length - 2][0] }
                                        { dashStyle: 'dot' }
                                ]
                                connectNulls: true
                        }
                        {
                                name: 'Pages'
                                data: pages
                                yAxis: 1
                                zoneAxis: 'x'
                                zones: [
                                        { value: pages[pages.length - 2][0] }
                                        { dashStyle: 'dot' }
                                ]
                                connectNulls: true
                        }
                ]
        chart = $('#timeline').highcharts()

round = (float, precison) ->
        Math.round(float * 10 * precison) / (10 * precison)

updateAchievements = (data) ->
        for key in ['num_words', 'pages']
                for id in ['hour', 'today', 'yesterday', 'this_week', 'week']
                        $("##{id} span.#{key}").text(round(data[key][id], 2))

$ ->
        if $('.visualization').length > 0 # See if we're on a paper_show page
                Highcharts.setOptions
                        global:
                                useUTC: false

                paper_id = $('#paper_id').html()
                updateSketches(paper_id)

                setInterval ->
                        updateSketches(paper_id)
                , update_interval
