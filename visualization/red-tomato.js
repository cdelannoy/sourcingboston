function createVisualization() {

    // adapted from https://bl.ocks.org/mbostock/3887051
    var svg = d3.select("svg"),
    margin = {
        top: 40, 
        right: 20, 
        bottom: 50, 
        left: 50
    },
    width = +svg.attr("width") - margin.left - margin.right,
    height = +svg.attr("height") - margin.top - margin.bottom,
    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var x0 = d3.scaleBand()
        .rangeRound([0, width])
        .paddingInner(0.1);

    var x1 = d3.scaleBand()
        .padding(0.05);

    var y = d3.scaleLinear()
        .rangeRound([height, 0]);

    var z = d3.scaleOrdinal()
        .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

    d3.csv("sample.csv", function(d) {
      return d;
    },
    
    function(error, data) {
        if (error) throw error;

        convertToNumeric(data);
        createDropdownOptions(data);
        var productData = getProductData(data, document.querySelector('option').value);
        var prices = Object.keys(productData[0]).filter(x => x != "group");
        var legendLabels = {
            ecoPrice: "ECO",
            nonEcoPrice: "Non-ECO"
        };

        x0.domain(productData.map(function(d) { return d.group; }));
        x1.domain(prices).rangeRound([0, x0.bandwidth()]);
        y.domain([0, 
            d3.max(productData, function(d) {
                return d3.max(prices, function(price) { 
                    return d[price]; 
                }); 
            })])
        .nice();

        g.append("g")
            .selectAll("g")
            .data(productData)
            .enter().append("g")
            .attr('class', 'bar-group')
            .attr("transform", function(d) { return "translate(" + x0(d.group) + ",0)"; })
            .selectAll("rect")
            .data(function(d) {
                return prices.map(function(price) { 
                    return {key: price, value: d[price]}; 
                }); 
            })
            .enter().append("rect")
            .attr('class', 'bar')
            .attr("x", function(d) { return x1(d.key); })
            .attr("y", function(d) { return y(d.value); })
            .attr("width", x1.bandwidth())
            .attr("height", function(d) { return height - y(d.value); })
            .attr("fill", function(d) { return z(d.key); });

        g.append("g")
            .attr("class", "x-axis")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x0));

        g.append("g")
            .attr("class", "y-axis")
            .call(d3.axisLeft(y));

        var legend = g.append("g")
            .attr("font-size", 10)
            .attr("text-anchor", "start")
            .selectAll("g")
            .data(prices)
            .enter().append("g")
            .attr("transform", function(d, i) { return "translate(" + (width/ 2 + i * 20 - 60) + ",0)"; });

        legend.append("rect")
            .attr("x", 40)
            .attr("width", 19)
            .attr("height", 19)
            .attr("fill", z);

        legend.append("text")
            .attr("x", function(d, i) {
                if(i === 0) {
                    return 12;
                } else {
                    return 65;
                }
            })
            .attr("y", 9.5)
            .attr("dy", "0.32em")
            .text(function(d) { return legendLabels[d]; });

        // axis labels
        g
            .append('text')
            .attr('class', 'x-axis-label')
            .attr('x', width/ 2)
            .attr('y', height + 30)
            .attr('text-anchor', 'middle')
            .attr('dominant-baseline', 'hanging')
            .text('Group');

        var xCoord = -40;

        g
            .append('text')
            .attr('class', 'y-axis-label')
            .attr('x', xCoord)
            .attr('y', height / 2)
            .attr('transform', 'rotate(-90,' + xCoord + ',' + height / 2 + ')')
            .attr('text-anchor', 'middle')
            .attr('dominant-baseline', 'baseline')
            .text('$');

        // title
        g
            .append('text')
            .attr('class', 'title')
            .attr('x', width / 2)
            .attr('y', -20)
            .attr('text-anchor', 'middle')
            .attr('dominant-baseline', 'baseline')
            .style('font-size', 24)
            .text('ECO Price Premium');

        // when new product is selected
        d3.select('#dropdown').on('change', function() {
            productData = getProductData(data, event.target.value);
            var duration = 1000;

            y.domain([0, 
                d3.max(productData, function(d) {
                    return d3.max(prices, function(price) { 
                        return d[price]; 
                    }); 
                })])
            .nice();

            d3
                .select('.y-axis')
                .transition()
                .duration(duration)
                .call(d3.axisLeft(y));

            var bars = g
                .selectAll('.bar-group')
                .data(productData)
                .selectAll('.bar')
                .data(function(d) {
                    return prices.map(function(price) { 
                        return {key: price, value: d[price]}; 
                    }); 
                });

            bars
                .transition()
                .duration(duration)
                .attr("y", function(d) { 
                    return y(d.value); 
                })
                .attr("height", function(d) { 
                    return height - y(d.value); 
                });
        });

    });
};

function convertToNumeric(data) {
    var numericColumns = ["Farmer_Price", "RT_Price", "Retail_Price", "ECO_Indicator", "Sold_ECO_Indicator"];

    data.forEach(x => {
        numericColumns.forEach(y => {
            x[y] = +x[y];
        })
    });
}

function createDropdownOptions(data) {
    var options = data.filter(x => x.ECO_Indicator == 1);
    var dropdown = document.getElementById("dropdown");
    options.forEach(x => {
        var currOption = document.createElement("option");
        currOption.text = x.Group;
        currOption.value = x.Group;
        dropdown.appendChild(currOption);
    });
}

function getProductData(data, selectedProductName) {
    var selectedProduct = data.filter(x => x.Group == selectedProductName);
    var eco = selectedProduct.filter(x => x.ECO_Indicator == 1)[0];
    var nonEco = selectedProduct.filter(x => x.ECO_Indicator == 0)[0];

    return [{
        group: "Farmers",
        ecoPrice: eco.Farmer_Price,
        nonEcoPrice: nonEco.Farmer_Price
    }, {
        group: "Red Tomato",
        ecoPrice: eco.RT_Price,
        nonEcoPrice: nonEco.RT_Price
    }, {
        group: "Retail",
        ecoPrice: eco.Retail_Price,
        nonEcoPrice: nonEco.Retail_Price
    }];
}

createVisualization();
