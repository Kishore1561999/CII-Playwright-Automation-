import ApexCharts from 'apexcharts';
import html2pdf from 'html2pdf.js';
import { PDFDocument } from 'pdf-lib';

$(document).on('turbolinks:load', function () {
  if (window.location.href.includes('analytics_graph')) {
  const currentYear = new Date().getFullYear();
  const previousYear = currentYear-1;
  const questions = ['PB-01', 'PB-02', 'PB-03', 'PB-04', 'PB-05', 'PB-06', 'PB-07', 'PB-08', 'PB-09', 'PB-10', 'PB-11', 'PB-12', 'PB-13', 'PB-14', 'PB-15', 'PB-16', 'PB-17', 'PB-18', 'PB-19', 'PB-20', 'PB-21', 'PB-22', 'PB-23', 'PB-24', 'PB-25', 'PB-26', 'PB-27', 'PB-28', 'PB-29', 'PB-30', 'PB-31', 'PB-32', 'PB-33', 'PB-34', 'PB-35'];
  const repeatQuestions = ['PB-03', 'PB-05', 'PB-06', 'PB-07', 'PB-08', 'PB-09', 'PB-10', 'PB-14', 'PB-15', 'PB-19', 'PB-22', 'PB-26', 'PB-27', 'PB-35'];

  const chartFunctions = {
    'PB-01': chartOne,
    'PB-02': chartTwo,
    'PB-03': chartThree,
    'PB-04': createTableChart,
    'PB-05': createChart,
    'PB-06': chartSix,
    'PB-07': chartSeven,
    'PB-08': chartEight,
    'PB-09': chartNine,
    'PB-10': chartTen,
    'PB-11': chartEleven,
    'PB-12': chartTwelve,
    'PB-13': chartThirteen,
    'PB-14': chartFourteen,
    'PB-15': chartFifteen,
    'PB-19': chartNineteen,
    'PB-20': chartTwenty,
    'PB-21': chartTwentyOne,
    'PB-22': chartTwentyTwo,
    'PB-23': chartTwentyThree,
    'PB-24': chartTwentyFour,
    'PB-25': TwentyFive,
    'PB-26': chartTwentySix,
    'PB-27': chartTwentySeven,
    'PB-34': chartThirtyFour,
    'PB-35': chartThirtyFive
  };

questions.forEach(question => {
    const runFetch = (status = 'default') => {
        const params = new URLSearchParams({ question, status });
        fetch('fetch_analytics_graphs_data?' + params)
            .then(response => response.json())
            .then(data => {
                const chartFunction = chartFunctions[data.question];
                if (chartFunction) {
                    chartFunction(data);
                } else {
                    console.warn('No handler for question', data.question);
                }
            })
            .catch(error => console.error('Error fetching chart data for question', question, ':', error));
    };
    // Run the fetch once
    runFetch();
    // If the question is in the repeatQuestions list, run the fetch a second time with a unique status
    if (repeatQuestions.includes(question)) {
        runFetch('cross');
    }
});

  const chartConfigs = [
    { id: 'PB-16', title: 'Employees & Workers = '+currentYear+'' },
    { id: 'PB-17', title: 'Employees & Workers = '+currentYear+'' },
    { id: 'PB-18', title: 'Employees & Workers = '+currentYear+'' }
  ];

   
  chartConfigs.forEach(config => {
      chartFunctions[config.id] = function(data) {
          renderChartData(data, `#chart${config.id.toLowerCase()}`, config.title, config.id);
      };
  });

  const dataPointsConfig = [
    { id: 'PB-28'},
    { id: 'PB-29' },
    { id: 'PB-30'},
    { id: 'PB-31'},
    { id: 'PB-32'}, 
    { id: 'PB-33'}, 
  ];

  dataPointsConfig.forEach(config => {
    chartFunctions[config.id] = function(data) {
        creatingDataButtons(data, config.id);
    };
  });

  function chartOne(data) {
    const categories = [
        //'PM',
        'PF',
        //'OTPM',
        'OTPF',
        //'TM',
        'TF'
    ];
     
    var answer_1 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.01;
    var answer_2 = data.answers[5].orignalans == '' || data.answers[5].orignalans == null ? null : data.answers[5].ans + 0.02;
    var answer_3= data.answers[9].orignalans == '' || data.answers[9].orignalans == null ? null : data.answers[9].ans + 0.03;

    let companyValueData_1 = interpolateData([
      { x: 'PF', y: answer_1 },
      { x: 'OTPF', y: answer_2 },
      { x: 'TF', y: answer_3 }
    ]);

    let discreteMarkers_1 = [
      ...companyValueData_1.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const seriesDataOne = [
        {
            name: 'Max & Min',
            color: '#B7D93D',
            type: 'rangeBar',
            data: [
                { x: 'PF', y: [data.company_data[1].maximum, data.company_data[1].minimum] },
                { x: 'OTPF', y: [data.company_data[5].maximum, data.company_data[5].minimum] },
                { x: 'TF', y: [data.company_data[9].maximum, data.company_data[9].minimum] }
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
                { x: 'PF', y: data.company_data[1].average + 0.01 },
                { x: 'OTPF', y: data.company_data[5].average + 0.02 },
                { x: 'TF', y: data.company_data[9].average + 0.03 }
            ]
        },
        {
            name: 'Company Value',
            type: 'line',
            color: '#FF662B',
            data: companyValueData_1.data,
        }
    ];

    var answer_4 = data.answers[3].orignalans == '' || data.answers[3].orignalans == null ? null : data.answers[3].ans + 0.01;
    var answer_5 = data.answers[7].orignalans == '' || data.answers[7].orignalans == null ? null : data.answers[7].ans + 0.02;
    var answer_6= data.answers[11].orignalans == '' || data.answers[11].orignalans == null ? null : data.answers[11].ans + 0.03;
  

    let companyValueData_2 = interpolateData([
      { x: 'PF', y: answer_4 },
      { x: 'OTPF', y: answer_5 },
      { x: 'TF', y: answer_6 }
    ]);

    let discreteMarkers_2 = [
      ...companyValueData_2.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const seriesDataTwo = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
                { x: 'PF', y: [data.company_data[3].maximum, data.company_data[3].minimum] },
                { x: 'OTPF', y: [data.company_data[7].maximum, data.company_data[7].minimum] },
                { x: 'TF', y: [data.company_data[11].maximum, data.company_data[11].minimum] }
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
                { x: 'PF', y: data.company_data[3].average + 0.01 },
                { x: 'OTPF', y: data.company_data[7].average + 0.02 },
                { x: 'TF', y: data.company_data[11].average + 0.03 }
            ]
        },
        {
            name: 'Company Value',
            type: 'line',
            color: '#FF662B',
            data: companyValueData_2.data,
        }
    ];

    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb1_button1', 'pb1_button2', 'pb1_button3', 'pb1_button4', 'pb1_button5', 'pb1_button6'];
      const indices = [1, 5, 9, 3, 7, 11];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer > average) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (originalAnswer < average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (originalAnswer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }
      });
    } else {
      $('.pb1_commonclass').addClass('grey-hexagon');
    }
    
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
    renderAvgChart("#chartpb-01-1", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of female', false, 300, 100, 10, customYaxisLabels, discreteMarkers_1);
    renderAvgChart("#chartpb-01-2", seriesDataTwo, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of female', false, 300, 100, 10, customYaxisLabels, discreteMarkers_2);
  }

  function chartThree(data) {
    const categories = [
        'Board of directors',
        'Senior Management'
    ];
    var industryStatus = data.industry_status;

    var answer_1 = (data.answers[0].orignalans == '' || data.answers[0].orignalans == null) ? null : parseFloat(data.answers[0].ans) + 0.01;
    var answer_2 = (data.answers[1].orignalans == '' || data.answers[1].orignalans == null) ? null : parseFloat(data.answers[1].ans) + 0.02;
    
    let companyValueData = interpolateData([
      { x: 'Board of directors', y: answer_1 },
      { x: 'Senior Management', y: answer_2 }
    ]);

    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const seriesDataThree = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
                { x: 'Board of directors', y: [data.percentage[0].values.maximum, data.percentage[0].values.minimum] },
                { x: 'Senior Management', y: [data.percentage[1].values.maximum, data.percentage[1].values.minimum] }
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
                { x: 'Board of directors', y: data.percentage[0].values.average + 0.01 },
                { x: 'Senior Management', y: data.percentage[1].values.average + 0.02 }
            ]
        },
        {
            name: 'Company Value',
            type: 'line',
            color: '#FF662B',
            data: companyValueData.data
        }
    ];
    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb3_button1', 'pb3_button2'];
      const indices = [0, 1];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.percentage[indices[idx]].values.average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer > average) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (originalAnswer < average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (originalAnswer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }
      });
    } else {
      $('.pb3_commonclass').addClass('grey-hexagon');
    }
    }
    
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
    if(industryStatus == 'default') {
      renderAvgChart("#chartpb-03-1", seriesDataThree, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of women', false, 300, 100, 5, customYaxisLabels, discreteMarkers);
    }else {
      renderAvgChart("#chartpb-03-2", seriesDataThree, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of women', false, 300, 100, 5, customYaxisLabels, discreteMarkers);
    }
    }

  function chartTwo(data) {

      const chartData_1 = [
        convertPercentToNumber(data.percentage[0].values.maximum),
        convertPercentToNumber(data.percentage[1].values.maximum),
      ];
    
      const chartData_2 = [
        convertPercentToNumber(data.percentage[0].values.sum),
        convertPercentToNumber(data.percentage[1].values.sum),
      ];
    
      const chartData_3 = [
        convertPercentToNumber(data.percentage[0].values.minimum),
        convertPercentToNumber(data.percentage[1].values.minimum),
      ];
      var answer_1 = data.answers[0].ans == '' || data.answers[0].ans == null ? 'NA' : data.answers[0].ans;
      var answer_2 = data.answers[1].ans == '' || data.answers[1].ans == null ? 'NA' : data.answers[1].ans;
      const chartData_4 = [
        answer_1,
        answer_2,
      ];
    
      const minValue = 1;
      const ansMinValue = 1;
      const chartDataProcessed_1 = chartData_1.map(value => value === 0 ? minValue : value);
      const chartDataProcessed_2 = chartData_2.map(value => value === 0 ? minValue : value);
      const chartDataProcessed_3 = chartData_3.map(value => value === 0  ? minValue : value);
      const chartDataProcessed_4 = chartData_4.map(value => value === 'NA' || value === 0 ? ansMinValue : value);
      
      const originalData = [
        chartData_1,
        chartData_2,
        chartData_3,
        chartData_4
      ];
    
      var options = {
        series: [{
          name: 'Maximum',
          color: '#00D4E1',
          data: chartDataProcessed_1
        }, {
          name: 'Total',
          color: '#B7D93D',
          data: chartDataProcessed_2
        }, {
          name: 'Minimum',
          color: '#FFFF00',
          data: chartDataProcessed_3
        }, {
          name: 'Company Value',
          width: '20',
          color: '#FF662B',
          data: chartDataProcessed_4
        }],
        chart: {
          type: 'bar',
          height: 430,
          toolbar: {
            show: false // This will hide the toolbar
          }
        },
        plotOptions: {
          bar: {
            horizontal: true,
            dataLabels: {
              position: 'end', // Position the data label at the end of the bar
            },
            barHeight: '70%',
          }
        },
        dataLabels: {
          enabled: true,
          offsetX: 0,
          offsetY: 0,
          style: {
            fontSize: '12px',
            colors: ['#000'], // Set the color to black
            textAnchor: 'start' // Adjust this value to 'start' or 'end' as needed
          },
          background: {
            enabled: true,
            foreColor: '#fff',
            padding: 4,
            borderRadius: 2,
            borderWidth: 1,
            borderColor: '#333',
          },
          formatter: function (val, opts) {
            const seriesIndex = opts.seriesIndex;
            const dataPointIndex = opts.dataPointIndex;
            return originalData[seriesIndex][dataPointIndex]; // Show the original value
          }
        },
        stroke: {
          show: true,
          width: 1,
          colors: ['#fff']
        },
        tooltip: {
          shared: true,
          intersect: false
        },
        xaxis: {
          min: 0, max: 100,
          categories: ['Employees', 'Workers'],
          style: {
            fontSize: '12px',
            fontFamily: 'Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif', // Set the font family for the legend text
            cssClass: 'apexcharts-yaxis-title'
          },
          labels: {
            show: false // This hides the x-axis labels (scale)
          }
        },
        yaxis: {
          title: {
            text: 'Number of differently abled individuals',
            rotate: -90,
            offsetX: 0,
            offsetY: 0,
            style: {
              color: undefined,
              fontSize: '12px',
              fontWeight: 600,
              cssClass: 'apexcharts-yaxis-title'
            }
          }
        },
      };
    
      var chart = new ApexCharts(document.querySelector("#chartpb-02"), options);
      chart.render();
    }    

  
  function chartSix(data) {
    const ethicsData = data.valuesix[0].ethics;
    const cocData = data.valuesix[1];

    const ethicsSeries = [
      convertPercentToNumber(ethicsData.percent_option_a),
      convertPercentToNumber(ethicsData.percent_option_b),
      convertPercentToNumber(ethicsData.percent_both_a_and_b),
      convertPercentToNumber(ethicsData.percent_option_2),
      convertPercentToNumber(ethicsData.percent_option_3),
    ];
    var industryStatus = data.industry_status;
    if (ethicsSeries.every(value => value === 0)) {
      $('#chartpb-06-1').text('No data available to show the chart');
      $('#chartpb-06-1').css('margin-left', '170px');
      $('#chartpb-06-1').css('width', '300px');
      $('.pb-06-2-industry').css('margin-top', '30px');
      $('#chartpb-06-1').css('font-size', '11px');
      $('#chartpb-06-1').css('margin-top', '-20px');
      $('.pb-06-heading').css('margin-left', '200px');
    } else {
      if(industryStatus == 'default') {
        renderPieChart("#chartpb-06-1", ethicsSeries, ['% of companies with Ethics Policy/ CoC<br> for Board of Directors/KMPs', '% of companies with Ethics Policy/ CoC<br> for employees', '% of companies with Ethics Policy/ CoC<br> for both BoD/KMPs and employees', '% of companies with no Ethics Policy/ CoC', '% of companies with no clear information'], 540, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B', '#780096'], true);
      }else {
        renderPieChart("#chartpb-06-cross-1", ethicsSeries, ['% of companies with Ethics Policy/ CoC<br> for Board of Directors/KMPs', '% of companies with Ethics Policy/ CoC<br> for employees', '% of companies with Ethics Policy/ CoC<br> for both BoD/KMPs and employees', '% of companies with no Ethics Policy/ CoC', '% of companies with no clear information'], 540, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B', '#780096'], true);
      }
    }

    if (convertPercentToNumber(cocData.coc) === 0) {
      $('#chartpb-06-2').text('No data available to show the chart');
      $('#chartpb-06-2').css('width',"");
    } else {
      if(industryStatus == 'default') {
        renderCircleChart("#chartpb-06-2", [convertPercentToNumber(cocData.coc.option1), convertPercentToNumber(cocData.coc.option2)], ['BoD/KMPs'], ['#150E40', '#B7D93D']);
      }else {
        renderCircleChart("#chartpb-06-cross-2", [convertPercentToNumber(cocData.coc.option1), convertPercentToNumber(cocData.coc.option2)], ['BoD/KMPs'], ['#150E40', '#B7D93D']);
      }
    }

    if (convertPercentToNumber(cocData.empcoc) === 0) {
      $('#chartpb-06-3').text('No data available to show the chart');
      $('#chartpb-06-3').css('width',"");
    } else {
      if(industryStatus == 'default') {
        renderCircleChart("#chartpb-06-3", [convertPercentToNumber(cocData.empcoc.option1), convertPercentToNumber(cocData.empcoc.option2)], ['Employee COC'], ['#150E40', '#B7D93D']);
      }else{
        renderCircleChart("#chartpb-06-cross-3", [convertPercentToNumber(cocData.empcoc.option1), convertPercentToNumber(cocData.empcoc.option2)], ['Employee COC'], ['#150E40', '#B7D93D']);
      }
    }

    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name === 'Information Available') {
      setSixthHexagonClass('.pb6_button1', data.answers[0].ans, data.answers[1].ans);
      setSixthHexagonClass('.pb6_button2', data.answers[2].ans, data.answers[3].ans);
    } else if (data.answers[0].checkbox_name === 'No such policies in place') {
      $('.pb6_commonclass').addClass('red-hexagon');
    } else {
      $('.pb6_commonclass').addClass('grey-hexagon');
    }
    }

  }

  function renderConditionalPieChart(data, container, labels, width, color, legendStatus) {
    const series = data.percentage.map(item => convertPercentToNumber(item.percentage));
    if (series.every(value => value === 0)) {
      $(container).text('No data available to show the chart');
      $(container).css('margin-left', '265px');
      $(container).css('font-size', '11px');
      $(container).css('margin-top', '-20px');
      console.log(container);
      if (container == '#chartpb-07-1') {
        $('.pb-07-heading').css('margin-left', '240px');
        $('#chartpb-07-1').css('width', '300px');
        $('#chartpb-07-1').css('margin-left', '47px');
        $('#chartpb-07-1').css('margin-top', '0px');
      }else if(container == '#chartpb-07-2'){
        $('#chartpb-07-2').css('width', '300px');
        $('#chartpb-07-2').css('margin-left', '47px');
        $('#chartpb-07-2').css('margin-top', '0px')
      }else if(container == '#chartpb-08-1'){
        $('.pb-08-legends').hide();
      }else if(container == '#chartpb-10-1'){
        $('.pb-10-heading').css('margin-left', '240px');
        $('#chartpb-10-1').css('width', '300px');
        $('#chartpb-10-1').css('margin-left', '67px');
        $('#chartpb-10-1').css('margin-top', '0px');
      }else if(container == '#chartpb-10-2'){
        $('#chartpb-10-2').css('width', '300px');
        $('#chartpb-10-2').css('margin-left', '67px');
        $('#chartpb-10-2').css('margin-top', '0px');
      }else if(container == '#chartpb-15-1'){
        $('.pb-15-heading').css('margin-left', '242px');
        $('#chartpb-15-1').css('width', '300px');
        $('#chartpb-15-1').css('margin-left', '84px');
        $('#chartpb-15-1').css('margin-top', '0px');
      }else if(container == '#chartpb-15-2'){
        $('#chartpb-15-2').css('width', '300px');
        $('#chartpb-15-2').css('margin-left', '84px');
        $('#chartpb-15-2').css('margin-top', '0px');
      }else if(container == '#chartpb-26-1'){
        $('#chartpb-26-1').css('margin-left', '58px');
        $('#chartpb-26-1').css('width', '300px');
        $('#chartpb-26-1').css('margin-top', '0px');
      }else if(container == '#chartpb-26-2'){
        $('#chartpb-26-2').css('margin-left', '58px');
        $('#chartpb-26-2').css('width', '300px');
        $('#chartpb-26-2').css('margin-top', '0px');
      }else if(container == '#chartpb-35-1'){
        $('.pb-35-heading').css('margin-left', '280px');
        $('#chartpb-35-1').css('margin-left', '78px');
        $('#chartpb-35-1').css('width', '300px');
        $('#chartpb-35-1').css('margin-top', '0px');
      }else if(container == '#chartpb-35-2'){
        $('#chartpb-35-2').css('margin-left', '78px');
        $('#chartpb-35-2').css('width', '300px');
        $('#chartpb-35-2').css('margin-top', '0px');
      }
    } else {
      renderPieChart(container, series, labels, width, color, legendStatus);
    }
  }

  function setSixthHexagonClass(button, answer, policyAnswer) {
    if (answer) {
      if (policyAnswer === 'Internal Policy') {
        $(button).addClass('yellow-hexagon');
      } else if (policyAnswer === 'Publicly available Policy') {
        $(button).addClass('green-hexagon');
      } else {
        $(button).addClass('grey-hexagon');
      }
    } else {
      $(button).addClass('grey-hexagon');
    }
  }

  function chartSeven(data) {
    
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
      const $button = $('.pb7_button1');
      $button.addClass('grey-hexagon');  // Set default class
    if (data.answers[0].checkbox_name == 'Information available') {
          if (data.answers[0].ans == 'Internal Policy') {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          } else if (data.answers[0].ans == 'Publicly available Policy') {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (data.answers[0].ans == 'No such policy in place') {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          }
    } else {
      $('.pb7_commonclass').addClass('grey-hexagon');
    }
    }
    if (industryStatus == 'default'){
      renderConditionalPieChart(data, '#chartpb-07-1', ['% of companies with Internal Policy', '% of companies with Publicly available policy', '% of companies with no such Policy'], 520, ['#150E40', '#B7D93D', '#00D4E1'], true);
    }else {
      renderConditionalPieChart(data, '#chartpb-07-2', ['% of companies with Internal Policy', '% of companies with Publicly available policy', '% of companies with no such Policy'], 520, ['#150E40', '#B7D93D', '#00D4E1'], true);
    }
    
  }

  function chartEight(data) {
    
      // Set default class

    const answerClasses = {
      'Dedicated Board ESG/Sustainability committee': 'green-hexagon',
      'ESG/Sustainability function part of other board committee': 'yellow-hexagon',
      'No board level committee, but CSO or dedicated executive director for sustainability issues': 'green-hexagon',
      'No dedicated board committee, but MD/CEO/CFO/COO or any other executive with multiple responsibilities is also responsible for sustainability issues': 'yellow-hexagon',
      'No dedicated board committee but a Non-executive director is responsible for sustainability issues': 'yellow-hexagon',
      'No board level, only operational level ESG committee/Individual': 'red-hexagon',
      'Company reports to have not defined the responsibility in BRSR': 'red-hexagon'
    };
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
      const $button = $('.pb8_button1');
      $button.addClass('grey-hexagon');
    if (data.answers[0].checkbox_name === 'information_available') {
      const hexagonClass = answerClasses[data.answers[0].ans];
      if (hexagonClass) {
        $button.removeClass('grey-hexagon').addClass(hexagonClass);
      }
    } else {
      $('.pb8_commonclass').addClass('grey-hexagon');
    }
    }
    if (industryStatus == 'default'){
      renderConditionalPieChart(data, '#chartpb-08-1', ['% of companies with dedicated Board ESG/Sustainability committee', '% of companies where ESG/Sustainability function part of other board committee', '% of companies with no dedicated board committee, but CSO or dedicated executive director for sustainability issues', '% of companies with no dedicated board committee, but MD/CEO/CFO/COO or any other executive with multiple responsibilities is also responsible for sustainability issues', '% of companies with no dedicated board committee but a non-executive director is responsible for sustainability issues', '% of companies with no board level responsibility but an operational level ESG committee/Individual', '% of companies which have not defined the responsibility'], 340, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B', '#780096', '#FFA837', '#BA4A00'], false);
    }else {
      renderConditionalPieChart(data, '#chartpb-08-2', ['% of companies with dedicated Board ESG/Sustainability committee', '% of companies where ESG/Sustainability function part of other board committee', '% of companies with no dedicated board committee, but CSO or dedicated executive director for sustainability issues', '% of companies with no dedicated board committee, but MD/CEO/CFO/COO or any other executive with multiple responsibilities is also responsible for sustainability issues', '% of companies with no dedicated board committee but a non-executive director is responsible for sustainability issues', '% of companies with no board level responsibility but an operational level ESG committee/Individual', '% of companies which have not defined the responsibility'], 340, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B', '#780096', '#FFA837', '#BA4A00'], false);
    }
  }

  function chartNine(data) {
    const categories = [
        'BD',
        'KMP',
        'Kmps',
        'Employees',
        'VCP'
    ];

   
      var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
      var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;
      var answer_3 = data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.03;
      var answer_4 = data.answers[3].orignalans == '' || data.answers[3].orignalans == null ? null : data.answers[3].ans + 0.04;
      var answer_5 = data.answers[4].orignalans == '' || data.answers[4].orignalans == null ? null : data.answers[4].ans + 0.05;
    
    let companyValueData = interpolateData([
      { x: 'BD', y: answer_1 },
      { x: 'KMP', y: answer_2 },
      { x: 'Employees', y: answer_3 },
      { x: 'Workers', y: answer_4 },
      { x: 'VCP', y: answer_5 }
    ]);

    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];

    const seriesDataNine = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
                { x: 'BD', y: [data.company_data[0].maximum, data.company_data[0].minimum] },
                { x: 'KMP', y: [data.company_data[1].maximum, data.company_data[1].minimum] },
                { x: 'Employees', y: [data.company_data[2].maximum, data.company_data[2].minimum] },
                { x: 'Workers', y: [data.company_data[3].maximum, data.company_data[3].minimum] },
                { x: 'VCP', y: [data.company_data[4].maximum, data.company_data[4].minimum] },
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
                { x: 'BD', y: data.company_data[0].average + 0.01 },
                { x: 'KMP', y: data.company_data[1].average + 0.02 },
                { x: 'Employees', y: data.company_data[2].average + 0.03 },
                { x: 'Workers', y: data.company_data[3].average + 0.04 },
                { x: 'VCP', y: data.company_data[4].average + 0.05 }
            ]
        },
        {
          name: 'Company Value',
          type: 'line',
          color: '#FF662B',
          data: companyValueData.data
      }
    ];
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name == 'Information available') {
      const buttonClasses = ['pb9_button1', 'pb9_button2', 'pb9_button3', 'pb9_button4', 'pb9_button5'];
      const indices = [0, 1, 2, 3, 4];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer == 100) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          }else {
            if (originalAnswer > average) {
              $button.removeClass('grey-hexagon').addClass('green-hexagon');
            } else if (originalAnswer < average) {
              $button.removeClass('grey-hexagon').addClass('red-hexagon');
            } else if (originalAnswer == average) {
              $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
            }
          }
        }
      });
    } else {
      $('.pb9_commonclass').addClass('grey-hexagon');
    }
    }
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
    
      if (industryStatus == 'default'){
        renderAvgChart("#chartpb-09-1", seriesDataNine, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of individuals trained', false, 300, 100, 10, customYaxisLabels, discreteMarkers);
      }else{
        renderAvgChart("#chartpb-09-2", seriesDataNine, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of individuals trained', false, 300, 100, 10, customYaxisLabels, discreteMarkers);
      }
    }

  function chartTen(data) {
    

    const answerClasses = {
      'Internal Policy': 'yellow-hexagon',
      'Publicly available Policy': 'green-hexagon',
      'Company reported to have no such policy': 'red-hexagon'
    };
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
      const $button = $('.pb10_button1');
      $button.addClass('grey-hexagon');  // Set default class
    if (data.answers[0].checkbox_name === 'information_available') {
      const hexagonClass = answerClasses[data.answers[0].ans];
      if (hexagonClass) {
        $button.removeClass('grey-hexagon').addClass(hexagonClass);
      }
    } else {
      $('.pb10_commonclass').addClass('grey-hexagon');
    }
  }
      if (industryStatus == 'default'){
        renderConditionalPieChart(data, '#chartpb-10-1', ['% of companies with Internal Policy', '% of companies with Publicly available policy', '% of companies with no such Policy'], 550, ['#150E40', '#B7D93D', '#00D4E1'], true);
      }else {
        renderConditionalPieChart(data, '#chartpb-10-2', ['% of companies with Internal Policy', '% of companies with Publicly available policy', '% of companies with no such Policy'], 550, ['#150E40', '#B7D93D', '#00D4E1'], true);
      }
    }

  function chartEleven(data) {
    const r_d = [
      convertPercentToNumber(data.valueelven[0].trend),
      convertPercentToNumber(data.valueelven[0].investing),
      convertPercentToNumber(data.valueelven[0].commitment)
    ];

    const capex = [
      convertPercentToNumber(data.valueelven[1].trend),
      convertPercentToNumber(data.valueelven[1].investing),
      convertPercentToNumber(data.valueelven[1].commitment)
    ];

    const graphOneSeries = [
      ...r_d,
      ...capex
    ];
    console.log(data.valueelven[1].commitment, '--', convertPercentToNumber(data.valueelven[1].commitment));
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb11_button1', 'pb11_button2'];
      const indices = [0, 2];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer > 0) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else{
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          }
        }
      });
    } else {
      $('.pb11_commonclass').addClass('grey-hexagon');
    }
    // Define a small value to replace zero values
    const minValue = 2;

    // Preprocess the series data to replace zero values
    const r_dProcessed = r_d.map(value => value === 0 ? minValue : value);
    const capexProcessed = capex.map(value => value === 0 ? minValue : value);
    if (graphOneSeries.every(value => value === 0)) {
      $('#chartpb-11').text('No data available to show the chart');
      $('#chartpb-11').css('margin-left', '140px');
      $('#chartpb-11').css('font-size', '11px');
      $('.pb-11-legends').hide();
      //$('#chartpb-06-1').css('margin-top', '-20px');
      //$('.pb-06-heading').css('margin-left', '200px');
    } else {
      renderBarChart("#chartpb-11", r_dProcessed, capexProcessed, ['Trend', 'Investments', 'Commitment'], '', minValue);
    }

  }

  function chartTwelve(data) {
    renderAdditionalBarChart("#chartpb-12", data, ['% of input sourced sustainably'], ['']);
  }
  
  function renderAdditionalBarChart(container, data, title, ytitle) {
  
    const chartData_1 = [
      convertPercentToNumber(data.percentage[0].values.maximum)
    ];

    const chartData_2 = [
      convertPercentToNumber(data.percentage[0].values.average)
    ];

    const chartData_3 = [
      convertPercentToNumber(data.percentage[0].values.minimum)
    ];

    var answer_1 = data.answers[0].ans == '' || data.answers[0].ans == null ? 'NA' : data.answers[0].ans;
    const chartData_4 = [
      answer_1
    ];
    const minValue = 1;
    const ansMinValue = 1;
    const chartDataProcessed_1 = chartData_1.map(value => value === 0 ? minValue : value);
    const chartDataProcessed_2 = chartData_2.map(value => value === 0 ? minValue : value);
    const chartDataProcessed_3 = chartData_3.map(value => value === 0 ? minValue : value);
    const chartDataProcessed_4 = chartData_4.map(value => value === 'NA' || value === 0 ? ansMinValue : value);
     
    const originalData = [
      chartData_1,
      chartData_2,
      chartData_3,
      chartData_4
    ];
    var options = {
    series: [{
      name: 'Maximum',
      color: '#B7D93D',
      data: chartDataProcessed_1
    }, {
      name: 'Average',
      color: '#00D4E1',
      data: chartDataProcessed_2
    }, {
      name: 'Minimum',
      color: '#FFFF00',
      data: chartDataProcessed_3
    }, {
      name: 'Company Value',
      width: '20',
      color: '#FF662B',
      data: chartDataProcessed_4
    }],
    chart: {
      type: 'bar',
      height: 430,
      toolbar: {
        show: false // This will hide the toolbar
      }
    },
    plotOptions: {
      bar: {
        horizontal: true,
        dataLabels: {
          position: 'top',
        },
        barHeight: '70%',
      }
    },
    dataLabels: {
        enabled: true,
        offsetX: 0,
        offsetY: 0,
        style: {
          fontSize: '12px',
          colors: ['#000'], // Set the color to black
          textAnchor: 'start' // Adjust this value to 'start' or 'end' as needed
        },
        background: {
          enabled: true,
          foreColor: '#fff',
          padding: 4,
          borderRadius: 2,
          borderWidth: 1,
          borderColor: '#333',
        },
        formatter: function (val, opts) {
          const seriesIndex = opts.seriesIndex;
          const dataPointIndex = opts.dataPointIndex;
          return originalData[seriesIndex][dataPointIndex]; // Show the original value
        },
      style: {
        fontSize: '12px',
        colors: ['#000']
      }
    },
    stroke: {
      show: true,
      width: 1,
      colors: ['#fff']
    },
    tooltip: {
      shared: true,
      intersect: false
    },
    xaxis: {
      min: 0, max: 100,
      categories: ytitle,
      style: {
        fontSize: '12px',
        fontFamily: 'Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif', // Set the font family for the legend text
        cssClass: 'apexcharts-yaxis-title'
      }
    },
    yaxis: {
      title: {
        text: title,
        rotate: -90,
        offsetX: 0,
        offsetY: 0,
        style: {
          color: undefined,
          fontSize: '12px',
          //fontFamily: 'Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif', // Set the font family for the legend text
          fontWeight: 600,
          cssClass: 'apexcharts-yaxis-title'
        }
      }
    },
    };

    new ApexCharts(document.querySelector(container), options).render();
  }

  function renderAdditionalBarChartThirtyTwo(container, data, title, ytitle) {
  
    const chartData_1 = [
      convertPercentToNumber(data.company_data[0].maximum),
      convertPercentToNumber(data.company_data[2].maximum),
    ];
  
    const chartData_2 = [
      convertPercentToNumber(data.company_data[0].average),
      convertPercentToNumber(data.company_data[2].average),
    ];
  

      var answer_1 = data.answers[0].ans == '' || data.answers[0].ans == null ? 'NA' : data.answers[0].ans;
      var answer_2 = data.answers[2].ans == '' || data.answers[2].ans == null ? 'NA' : data.answers[2].ans;
      const chartData_3 = [
        answer_1,
        answer_2,
      ];
    
      const minValue = 1;
      const ansMinValue = 1;
      const chartDataProcessed_1 = chartData_1.map(value => value === 0 ? minValue : value);
      const chartDataProcessed_2 = chartData_2.map(value => value === 0 ? minValue : value);
      const chartDataProcessed_3 = chartData_3.map(value => value === 'NA' || value === 0 ? ansMinValue : value);
     
    const originalData = [
      chartData_1,
      chartData_2,
      chartData_3
    ];
    var options = {
    series: [{
      name: 'Maximum',
      color: '#B7D93D',
      data: chartDataProcessed_1
    }, {
      name: 'Average',
      color: '#00D4E1',
      data: chartDataProcessed_2
    }, {
      name: 'Company Value',
      width: '20',
      color: '#FF662B',
      data: chartDataProcessed_3
    }],
    chart: {
      type: 'bar',
      height: 300,
      toolbar: {
        show: false // This will hide the toolbar
      }
    },
    plotOptions: {
      bar: {
        horizontal: true,
        dataLabels: {
          position: 'top',
        },
        barHeight: '70%',
      }
    },
    dataLabels: {
        enabled: true,
        offsetX: 0,
        offsetY: 0,
        style: {
          fontSize: '12px',
          colors: ['#000'], // Set the color to black
          textAnchor: 'start' // Adjust this value to 'start' or 'end' as needed
        },
        background: {
          enabled: true,
          foreColor: '#fff',
          padding: 4,
          borderRadius: 2,
          borderWidth: 1,
          borderColor: '#333',
        },
        formatter: function (val, opts) {
          const seriesIndex = opts.seriesIndex;
          const dataPointIndex = opts.dataPointIndex;
          return originalData[seriesIndex][dataPointIndex]; // Show the original value
        },
      style: {
        fontSize: '12px',
        colors: ['#000']
      }
    },
    stroke: {
      show: true,
      width: 1,
      colors: ['#fff']
    },
    tooltip: {
      shared: true,
      intersect: false
    },
    xaxis: {
      min: 0, max: 100,
      categories: ytitle,
      style: {
        fontSize: '12px',
        fontFamily: 'Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif', // Set the font family for the legend text
        cssClass: 'apexcharts-yaxis-title'
      }
    },
    yaxis: {
      title: {
        text: title,
        rotate: -90,
        offsetX: 0,
        offsetY: 0,
        style: {
          color: undefined,
          fontSize: '12px',
          //fontFamily: 'Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif', // Set the font family for the legend text
          fontWeight: 600,
          cssClass: 'apexcharts-yaxis-title'
        }
      }
    },
    };

    new ApexCharts(document.querySelector(container), options).render();
  }
  function chartThirteen(data) {
    const graphOneSeries = [
      convertPercentToNumber(data.valuethirteen[2].lca_average.percent_1),
      convertPercentToNumber(data.valuethirteen[2].lca_average.percent_2),
      convertPercentToNumber(data.valuethirteen[2].lca_average.percent_3),
      convertPercentToNumber(data.valuethirteen[2].lca_average.percent_4)
    ];

    const textUI = [
      //convertPercentToNumber(data.valuethirteen[3].average)
    ];

    const graphThreeSeries = [
      convertPercentToNumber(data.valuethirteen[2].lca_average.percent_5)
    ];

    if (graphOneSeries.every(value => value === 0)) {
      $('#chartpb-13-1').text('No data available to show the chart');
      $('#chartpb-13-1').css('margin-left', '50px');
      $('#chartpb-13-1').css('font-size', '11px');
      $('#chartpb-13-1').css('margin-top', '');
    } else {
      renderPieChart("#chartpb-13-1", graphOneSeries, ['% of companies which conducted LCA', '% of companies which did not conduct LCA', '% of companies for which the indicator is not relevant', '% of companies with no clear information'], 580, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B'], true);
    }

    
      var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans;
      var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans;
    
    let companyValueData = interpolateData([
      { x: 'Internal LCA', y: answer_1},
      { x: 'External LCA', y: answer_2 }
    ]);

    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const categories = [
      'Internal LCA',
      'External LCA'
    ];
    const seriesDataTwo = [
      {
          name: 'Max & Min',
          type: 'rangeBar',
          color: '#B7D93D',
          data: [
              { x: 'Internal LCA', y: [data.valuethirteen[0].average.maximum, data.valuethirteen[0].average.minimum] },
              { x: 'External LCA', y: [data.valuethirteen[1].average.maximum, data.valuethirteen[1].average.minimum] }
          ]
      },
      {
          name: 'Avg Value',
          color: '#00D4E1',
          type: 'line',
          data: [
              { x: 'Internal LCA', y: data.valuethirteen[0].average.average},
              { x: 'External LCA', y: data.valuethirteen[1].average.average }
          ]
      },
      {
          name: 'Company Value',
          type: 'line',
          color: '#FF662B',
          data: companyValueData.data
      }
  ];
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
    renderAvgChart("#chartpb-13-2", seriesDataTwo, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of total revenue', false, 300, 100, 10, customYaxisLabels, discreteMarkers);
  
    const $button = $('.pb13_button1');
    //const $button2 = $('.pb13_button2');
    const $button3 = $('.pb13_button3');
    const $button4 = $('.pb13_button4');
    $button.addClass('grey-hexagon');  // Set default class

    if (data.answers[0].checkbox_name != '') {
      if(data.answers[0].checkbox_name == 'LCA conducted') {
        $button.removeClass('grey-hexagon').addClass('green-hexagon');
      } else if(data.answers[0].checkbox_name == 'No LCA conducted') {
        $button.removeClass('grey-hexagon').addClass('red-hexagon');
      }

      // if (data.answers[2].ans == 'LCA conducted internally') {
      //   if (data.answers[0].ans > data.valuethirteen[0].average.average) {
      //     $button2.removeClass('grey-hexagon').addClass('green-hexagon');
      //   } else if (data.answers[0].ans < data.valuethirteen[0].average.average) {
      //     $button2.removeClass('grey-hexagon').addClass('red-hexagon');
      //   } else if (data.answers[0].ans == data.valuethirteen[0].average.average) {
      //     $button2.removeClass('grey-hexagon').addClass('yellow-hexagon');
      //   }else{
      //     $button2.addClass('grey-hexagon');
      //   }
      // }else {
      //   $button2.addClass('grey-hexagon');
      // }

      if (data.answers[3].ans == 'LCA conducted externally') {
        if (data.answers[1].ans > data.valuethirteen[1].average.average) {
          $button3.removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (data.answers[1].ans < data.valuethirteen[1].average.average) {
          $button3.removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (data.answers[1].ans == data.valuethirteen[1].average.average) {
          $button3.removeClass('grey-hexagon').addClass('yellow-hexagon');
        }else{
          $button3.addClass('grey-hexagon');
        }
      }else {
        $button3.addClass('grey-hexagon');
      }
      
      if (data.answers[5].ans == 'Results communicated externally') {
        $button4.removeClass('grey-hexagon').addClass('green-hexagon');
      }else {
        $button4.removeClass('grey-hexagon').addClass('red-hexagon');
      }
      
      if(data.answers[0].checkbox_name == 'No information') {
        $('.pb13_commonclass').addClass('grey-hexagon');
      }
      if(data.answers[0].checkbox_name == 'Indicator is not relevant for the industry') {
        $('.company_buttons').hide();
        $('.pb13_commonclass').removeClass('grey-hexagon');
        $('.pb13_commonclass').removeClass('red-hexagon');
        $('.pb13_commonclass').removeClass('green-hexagon');
        $('.pb13_commonclass').removeClass('yellow-hexagon');
      }
    } else {
      $('.pb13_commonclass').addClass('grey-hexagon');
    }    

    if (graphThreeSeries.every(value => value === 0)) {
      $('#chartpb-13-3').text('No data available to show the chart');
      $('#chartpb-13-3').css('font-size', '11px');
      $('.pb-13-3-legend').hide();
      $('#chartpb-13-3').removeClass('about_indicator');
      $('#chartpb-13-3').css('margin-left', '135px');
      $('#chartpb-13-3').css('width','300px');
      $('.pb-13-3-heading').css('margin-left', '210px');
       
    } else {
      renderRadialBarChart("#chartpb-13-3", [convertPercentToNumber(data.valuethirteen[2].lca_average.percent_5)], ['Percentage'], '#B7D93D');
    }

  }

  function chartFourteen(data) {
    const graphOneSeries = [
      convertPercentToNumber(data.company_data[0].average),
      convertPercentToNumber(data.company_data[0].maximum),
      convertPercentToNumber(data.company_data[0].minimum),
      convertPercentToNumber(data.company_data[1].average),
      convertPercentToNumber(data.company_data[1].maximum),
      convertPercentToNumber(data.company_data[1].minimum),
    ];
    
      const categories = [
        ""+currentYear+"",
        ""+previousYear+""
    ];
    
      var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
      var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;
    
    let companyValueData = interpolateData([
      { x: ""+currentYear+"", y: answer_1 },
      { x: ""+previousYear+"", y: answer_2 }
    ]);

    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const seriesDataOne = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
                { x: ""+currentYear+"", y: [data.company_data[0].maximum, data.company_data[0].minimum] },
                { x: ""+previousYear+"", y: [data.company_data[1].maximum, data.company_data[1].minimum] }
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
                { x: ""+currentYear+"", y: data.company_data[0].average + 0.01 },
                { x: ""+previousYear+"", y: data.company_data[1].average + 0.02 }
            ]
        },
        {
            name: 'Company Value',
            type: 'line',
            color: '#FF662B',
            data: companyValueData.data
        }
    ];
      const customYaxisLabels = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
      var industryStatus = data.industry_status;
      if (industryStatus == 'default'){
        renderAvgChart("#chartpb-14-1", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of total revenue', false, 300, 10, 5, customYaxisLabels, discreteMarkers);
      }else {
        renderAvgChart("#chartpb-14-cross-1", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of total revenue', false, 300, 10, 5, customYaxisLabels, discreteMarkers);
      }
        
    
   
    if(industryStatus == 'default') {
      const $button = $('.pb14_button1');
      const $button2 = $('.pb14_button2');
      $button.addClass('grey-hexagon');  // Set default class
    if (data.answers[0].checkbox_name === 'information_available') {
        if (data.answers[0].orignalans != '') {
          const comparisonValue = data.company_data[0].average;
          $button.removeClass('grey-hexagon')
            .addClass(data.answers[0].orignalans > comparisonValue ? 'green-hexagon' :
                      data.answers[0].orignalans < comparisonValue ? 'red-hexagon' :
                      'yellow-hexagon');
        }
    
        $button2.addClass(data.answers[3].ans ? 'green-hexagon' : 'red-hexagon');
      
    } else {
      $('.pb14_commonclass').addClass('grey-hexagon');
    }
    }
    if (industryStatus == 'default'){
    if (convertPercentToNumber(data.company_data[3].percentage.percent_option_1) == 0 && convertPercentToNumber(data.company_data[3].percentage.percent_option_2) == 0) {
      $('#chartpb-14-2').text('No data available to show the chart');
      $('#chartpb-14-2').css('font-size',"11px");
      $('#chartpb-14-2').css('margin-top',"40px");
      $('#chartpb-14-2').css('width',"240px");
      $('.pb-14-2-legend').css('margin-left','400px');
      //$('#chartpb-14-2').css('margin-left','205px');
    } else {
        renderCircleChart("#chartpb-14-2", [convertPercentToNumber(data.company_data[3].percentage.percent_option_1), convertPercentToNumber(data.company_data[3].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
    }
    }else {
      renderCircleChart("#chartpb-14-cross-2", [convertPercentToNumber(data.company_data[3].percentage.percent_option_1), convertPercentToNumber(data.company_data[3].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
    }
  }

  function chartFifteen(data) {
    

    const answerClasses = {
      'Internal Policy': 'yellow-hexagon',
      'Publicly available Policy': 'green-hexagon',
      'Company has no such policy in place': 'red-hexagon'
    };
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
      const $button = $('.pb15_button1');
      $button.addClass('grey-hexagon');  // Set default class
    if (data.answers[0].checkbox_name === 'information_available') {
      const hexagonClass = answerClasses[data.answers[0].ans];
      if (hexagonClass) {
        $button.removeClass('grey-hexagon').addClass(hexagonClass);
      }
    } else {
      $('.pb15_commonclass').addClass('grey-hexagon');
    }
    }
      if (industryStatus == 'default'){
        renderConditionalPieChart(data, '#chartpb-15-1', ['% of companies with Internal Policy', '% of companies with Publicly available policy', '% of companies with no such Policy'], 540, ['#150E40', '#B7D93D', '#00D4E1'], true);
      }else{
        renderConditionalPieChart(data, '#chartpb-15-2', ['% of companies with Internal Policy', '% of companies with Publicly available policy', '% of companies with no such Policy'], 540, ['#150E40', '#B7D93D', '#00D4E1'], true);
      }
    }

  
  function renderChartData(data, containerId, chartTitle, id) {
    const categories = [
        'Perm Emp',
        'Other Perm Emp',
        'Total Emp',
        'Perm Work',
        'Other Perm Work',
        'Total Work'
    ];
   
      var answer_1= data.answers[0].orignalans == '' ||data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
      var answer_2 = data.answers[4].orignalans == '' || data.answers[4].orignalans ==null ? null : data.answers[4].ans + 0.02;
      var answer_3 = data.answers[8].orignalans == '' || data.answers[8].orignalans == null ? null : data.answers[8].ans + 0.03;
      var answer_4 = data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.04;
      var answer_5 = data.answers[6].orignalans == '' || data.answers[6].orignalans == null ? null : data.answers[6].ans + 0.05;
      var answer_6 = data.answers[10].orignalans == '' || data.answers[10].orignalans == null ? null : data.answers[10].ans + 0.06;
  
    let companyValueData = interpolateData([
      { x: 'Male Employees', y: answer_1 },
      { x: 'Female Employees', y: answer_2 },
      { x: 'Total Employees', y: answer_3 },
      { x: 'Male Workers', y: answer_4 },
      { x: 'Female Workers', y: answer_5 },
      { x: 'Total Workers', y: answer_6 }
    ]);

    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const seriesData = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
                { x: 'Male Employees', y: [data.company_data[0].maximum, data.company_data[0].minimum] },
                { x: 'Female Employees', y: [data.company_data[4].maximum, data.company_data[4].minimum] },
                { x: 'Total Employees', y: [data.company_data[8].maximum, data.company_data[8].minimum] },
                { x: 'Male Workers', y: [data.company_data[2].maximum, data.company_data[2].minimum] },
                { x: 'Female Workers', y: [data.company_data[6].maximum, data.company_data[6].minimum] },
                { x: 'Total Workers', y: [data.company_data[10].maximum, data.company_data[10].minimum] }
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
                { x: 'Male Employees', y: data.company_data[0].average + 0.01 },
                { x: 'Female Employees', y: data.company_data[4].average + 0.02 },
                { x: 'Total Employees', y: data.company_data[8].average + 0.03 },
                { x: 'Male Workers', y: data.company_data[2].average + 0.04 },
                { x: 'Female Workers', y: data.company_data[6].average + 0.05 },
                { x: 'Total Workers', y: data.company_data[10].average + 0.06 }
            ]
        },
        {
            name: 'Company Value',
            type: 'line',
            color: '#FF662B',
            data: companyValueData.data
        }
    ];
  if (id == 'PB-16' ) {
    var yaxis_title = '% of individuals covered';
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb16_button1', 'pb16_button2', 'pb16_button3', 'pb16_button4', 'pb16_button5', 'pb16_button6'];
      const indices = [0, 4, 8, 2, 6, 10];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if (answer > average) {
            console.log($button)
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (answer < average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (answer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }
      });
    } else {
      $('.pb16_commonclass').addClass('grey-hexagon');
    }
  }
  if (id == 'PB-17' ) {
    var yaxis_title = '% of individuals trained';
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb17_button1', 'pb17_button2', 'pb17_button3', 'pb17_button4', 'pb17_button5', 'pb17_button6'];
      const indices = [0, 4, 8, 2, 6, 10];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if (answer == 100) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          }else {
            if (answer > average) {
              console.log($button)
              $button.removeClass('grey-hexagon').addClass('green-hexagon');
            } else if (answer < average) {
              $button.removeClass('grey-hexagon').addClass('red-hexagon');
            } else if (answer == average) {
              $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
            }
          }
        }
      });
    } else {
      $('.pb17_commonclass').addClass('grey-hexagon');
    }
  }
  if (id == 'PB-18' ) {
    var yaxis_title = '% of individuals covered';
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb18_button1', 'pb18_button2', 'pb18_button3', 'pb18_button4', 'pb18_button5', 'pb18_button6'];
      const indices = [0, 4, 8, 2, 6, 10];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if (answer == 100) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          }else {
            if (answer > average) {
              console.log($button)
              $button.removeClass('grey-hexagon').addClass('green-hexagon');
            } else if (answer < average) {
              $button.removeClass('grey-hexagon').addClass('red-hexagon');
            } else if (answer == average) {
              $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
            }
          }
        }
      });
    } else {
      $('.pb18_commonclass').addClass('grey-hexagon');
    }
  }
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
    renderAvgChart(containerId, seriesData, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], yaxis_title, false, 300, 100, 10, customYaxisLabels, discreteMarkers);
  }

  function chartNineteen(data) {
    const graphOne = data.percentage[0].graphone;

    const graphOneSeries = [
      convertPercentToNumber(graphOne.percent_option_1),
      convertPercentToNumber(graphOne.percent_option_2),
      convertPercentToNumber(graphOne.percent_option_3)
    ];

    const graphTwoSeries = [
      convertPercentToNumber(data.percentage[0].graphtwo),
      convertPercentToNumber(data.percentage[1].graphtwo),
      convertPercentToNumber(data.percentage[2].graphtwo),
      convertPercentToNumber(data.percentage[3].graphtwo)
    ];

   

    const answerClasses = {
      'Company has OHS management system but no further details': 'green-hexagon',
      'Company has OHS management system & process to identify risks': 'yellow-hexagon',
      'Company has OHS management system and process to report risk': 'yellow-hexagon',
      'Company has OHS management system, process to identify & process to report risks': 'green-hexagon'
    };
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
      const $button = $('.pb19_button1');
      $button.addClass('grey-hexagon');  // Set default class
    if (data.answers[0].checkbox_name === 'information_available') {
      const hexagonClass = answerClasses[data.answers[0].ans];
      if (hexagonClass) {
        $button.removeClass('grey-hexagon').addClass(hexagonClass);
      }
    } else if (data.answers[0].checkbox_name === 'Company does not have OHS management system in place.'){
      $button.removeClass('grey-hexagon').addClass('red-hexagon');
    }else {
      $('.pb19_commonclass').addClass('grey-hexagon');
    }
    }
    if (graphOneSeries.every(value => value === 0)) {
      $('#chartpb-19-1').text('No data available to show the chart');
      $('#chartpb-19-1').css('margin-left', '57px');
      $('#chartpb-19-1').css('font-size', '11px');
      $('#chartpb-19-1').css('margin-top', '-20px');
      $('#chartpb-19-1').css('width', '300px');
      //$('.pb-06-heading').css('margin-left', '200px');
    } else {
      
      if (industryStatus == 'default'){
        renderPieChart("#chartpb-19-1", graphOneSeries, ['OHS management system in place', 'No management system', 'No information'], 480, ['#150E40', '#B7D93D', '#00D4E1'], true);
      }else {
        renderPieChart("#chartpb-19-cross-1", graphOneSeries, ['OHS management system in place', 'No management system', 'No information'], 480, ['#150E40', '#B7D93D', '#00D4E1'], true);
      }
    }

    if (graphTwoSeries.every(value => value === 0)) {
      $('#chartpb-19-2').text('No data available to show the chart');
      $('#chartpb-19-2').css('margin-left', '42px');
      $('#chartpb-19-2').css('font-size', '11px');
      $('#chartpb-19-2').css('margin-top', '-20px');
      $('#chartpb-19-2').css('width', '300px');
    } else {
      if (industryStatus == 'default'){
        renderPieChart("#chartpb-19-2", graphTwoSeries, ['No further details', 'Covers process to identify risk', 'Covers process to report risks', 'Covers both processes, to identify & to report risks'], 580, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B'], true);
      }else {
        renderPieChart("#chartpb-19-cross-2", graphTwoSeries, ['No further details', 'Covers process to identify risk', 'Covers process to report risks', 'Covers both processes, to identify & to report risks'], 580, ['#150E40', '#B7D93D', '#00D4E1', '#FF662B'], true);
      }
    }

  }

  function chartTwenty(data) {

    const graphOneSeries = [
      convertPercentToNumber(data.percentage[0].numbers.average),
      convertPercentToNumber(data.percentage[0].numbers.maximum),
      convertPercentToNumber(data.percentage[0].numbers.minimum),
      convertPercentToNumber(data.percentage[1].numbers.average),
      convertPercentToNumber(data.percentage[1].numbers.maximum),
      convertPercentToNumber(data.percentage[1].numbers.minimum),
      convertPercentToNumber(data.percentage[2].numbers.average),
      convertPercentToNumber(data.percentage[2].numbers.maximum),
      convertPercentToNumber(data.percentage[2].numbers.minimum),
      convertPercentToNumber(data.percentage[3].numbers.average),
      convertPercentToNumber(data.percentage[3].numbers.maximum),
      convertPercentToNumber(data.percentage[3].numbers.minimum)
    ];
    

    const graphTwoSeries = [
      convertPercentToNumber(data.percentage[4].percentage)
    ];
    
    if (data.answers[0].checkbox_name == 'information_available' && data.answers[4].firstcheckbox == 'Lost Time Injury Frequency Rate') {
      const buttonClasses = ['pb20_button1', 'pb20_button2'];
      const indices = [0, 2];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.percentage[indices[idx]].numbers.average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if (answer < average) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (answer > average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (answer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }        
      });
      
      const buttonClasses2 = ['pb20_button4', 'pb20_button5'];
      const indices2 = [5, 6];
      
      buttonClasses2.forEach((buttonClass2, idx) => {
        const answer = data.answers[indices2[idx]].ans;
        const average = data.percentage[indices2[idx]].numbers.average;
        const $button2 = $(`.${buttonClass2}`);
    
        $button2.addClass('grey-hexagon');  // Set default class
        if (answer) {
          if (answer == 0) {
            $button2.removeClass('grey-hexagon').addClass('green-hexagon');
          } else {
            $button2.removeClass('grey-hexagon').addClass('red-hexagon');
          } 
        }        
      });

      $('.pb20_button3').addClass(data.answers[4].ans ? 'green-hexagon' : 'red-hexagon');
      $('.pb20_button6').addClass(data.answers[7].ans ? 'green-hexagon' : 'red-hexagon');

    } else {
      $('.pb20_commonclass').addClass('grey-hexagon');
    }
    
    if (graphOneSeries.every(value => value === 0)) {
      $('#chartpb-20-1').text('No data available to show the chart');
      $('#chartpb-20-1').css('margin-left', '100px');
      $('#chartpb-20-1').css('font-size', '11px');
      $('#chartpb-20-1').css('margin-top', '-20px');
      $('#pb-20-1-heading').css('margin-left', '');
      $('.labelclass-20').hide();
    } else {
      const categories = [
        "Employees" +currentYear+"",
        "Employees" +previousYear+"",
        "Workers" +currentYear+"",
        "Workers" +previousYear+"",
      ];
      
        var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
        var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;
        var answer_3 = data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.03;
        var answer_4 = data.answers[3].orignalans == '' || data.answers[3].orignalans == null ? null : data.answers[3].ans + 0.04;
      
      let companyValueData = interpolateData([
        { x: "Employees" +currentYear+"", y: answer_1 },
        { x: "Employees" +previousYear+"", y: answer_2 },
        { x: "Workers" +currentYear+"", y: answer_3 },
        { x: "Workers" +previousYear+"", y: answer_4 }
      ]);
  
      let discreteMarkers = [
        ...companyValueData.nullIndices.map(index => ({
          seriesIndex: 2, // 'Company Value' series index
          dataPointIndex: index,
          size: 4, // Size for marker representing null values
          fillColor: '#808080', // Grey color for null value marker
          strokeColor: '#808080' // Grey border for null value marker
        }))
      ];

      const seriesDataOne = [
          {
              name: 'Max & Min',
              type: 'rangeBar',
              color: '#B7D93D',
              data: [
                  { x: "Employees" +currentYear+"", y: [data.percentage[0].numbers.maximum, data.percentage[0].numbers.minimum] },
                  { x: "Employees" +previousYear+"", y: [data.percentage[1].numbers.maximum, data.percentage[1].numbers.minimum] },
                  { x: "Workers" +currentYear+"", y: [data.percentage[2].numbers.maximum, data.percentage[2].numbers.minimum] },
                  { x: "Workers" +previousYear+"", y: [data.percentage[3].numbers.maximum, data.percentage[3].numbers.minimum] }
              ]
          },
          {
              name: 'Avg Value',
              color: '#00D4E1',
              type: 'line',
              data: [
                  { x: "Employees" +currentYear+"", y: data.percentage[0].numbers.average + 0.01 },
                  { x: "Employees" +previousYear+"", y: data.percentage[1].numbers.average + 0.02 },
                  { x: "Workers" +currentYear+"", y: data.percentage[2].numbers.average + 0.03 },
                  { x: "Workers" +previousYear+"", y: data.percentage[3].numbers.average + 0.04 }
              ]
          },
          {
              name: 'Company Value',
              type: 'line',
              color: '#FF662B',
              data:  companyValueData.data
          }
      ];
      const customYaxisLabels = ['0', '2', '4', '6', '8', '10', '12', '14', '16', '18', '20'];
      renderAvgChart("#chartpb-20-1", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], 'Frequency Rate', false, 380, 20, 5, customYaxisLabels, discreteMarkers);
    }

    if (graphTwoSeries.every(value => value === 0)) {
      $('#chartpb-20-2').text('No data available to show the chart');
      $('#chartpb-20-2').css('margin-left', '200px');
      $('#chartpb-20-2').css('width', '300px');
      $('#chartpb-20-2').css('font-size', '11px');
      $('.pb-20-2-legend').hide();
      //$('#pb-20-2-class1').removeClass('col-md-1')
      //$('#pb-20-2-class1').addClass('col-md-1')
      //$('#pb-20-2-class2').removeClass('col-md-5')
      //$('#pb-20-2-class2').addClass('col-md-7')
    } else {
      renderRadialBarChart("#chartpb-20-2", [convertPercentToNumber(data.percentage[4].percentage)], ['Percentage'], '#B7D93D');
    }


  }
  
  function chartTwentyOne(data) {
    const graphOneSeries = [
      convertPercentToNumber(data.company_data[0].average),
      convertPercentToNumber(data.company_data[0].maximum),
      convertPercentToNumber(data.company_data[0].minimum),
      convertPercentToNumber(data.company_data[1].average),
      convertPercentToNumber(data.company_data[1].maximum),
      convertPercentToNumber(data.company_data[1].minimum),
    ];

    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb21_button1', 'pb21_button2'];
      const indices = [0, 1];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if(originalAnswer == 100) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          }else {
            if (originalAnswer > average) {
              $button.removeClass('grey-hexagon').addClass('green-hexagon');
            } else if (originalAnswer < average) {
              $button.removeClass('grey-hexagon').addClass('red-hexagon');
            } else if (originalAnswer == average) {
              $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
            }
          }
          
        }        
      });

    } else {
      $('.pb21_commonclass').addClass('grey-hexagon');
    }
    
    if (graphOneSeries.every(value => value === 0)) {
      $('#chartpb-21').text('No data available to show the chart');
      $('#chartpb-21').css('font-size',"11px");
      $('#chartpb-21').css('margin-top', '-20px');
      $('#chartpb-21').css('margin-left',"50px");
      $('.labelclass-21').hide();
    } else {
      const categories = [
        "Health & Safety Practices",
        "Working Conditions"
      ];
      
        var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
        var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;
    
      let companyValueData = interpolateData([
        { x: "Health & Safety Practices", y: answer_1 },
        { x: "Working Conditions", y: answer_2}
      ]);
  
      let discreteMarkers = [
        ...companyValueData.nullIndices.map(index => ({
          seriesIndex: 2, // 'Company Value' series index
          dataPointIndex: index,
          size: 4, // Size for marker representing null values
          fillColor: '#808080', // Grey color for null value marker
          strokeColor: '#808080' // Grey border for null value marker
        }))
      ];

      const seriesDataOne = [
          {
              name: 'Max & Min',
              type: 'rangeBar',
              color: '#B7D93D',
              data: [
                  { x: "Health & Safety Practices", y: [data.company_data[0].maximum, data.company_data[0].minimum] },
                  { x: "Working Conditions", y: [data.company_data[1].maximum, data.company_data[1].minimum] }
              ]
          },
          {
              name: 'Avg Value',
              color: '#00D4E1',
              type: 'line',
              data: [
                  { x: "Health & Safety Practices", y: data.company_data[0].average + 0.01 },
                  { x: "Working Conditions", y: data.company_data[1].average + 0.02 }
              ]
          },
          {
              name: 'Company Value',
              type: 'line',
              color: '#FF662B',
              data:  companyValueData.data
          }
      ];
      const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
      renderAvgChart("#chartpb-21", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of operations covered', false, 300, 100, 5, customYaxisLabels, discreteMarkers);
    }
  }

  function chartTwentyTwo(data) {
    const categories = [
        'PE',
        'OPE',
        'TE',
        'PW',
        'OPW',
        'TW'
    ];
    
      var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
      var answer_2 = data.answers[4].orignalans == '' || data.answers[4].orignalans == null ? null : data.answers[4].ans + 0.02;
      var answer_3 = data.answers[8].orignalans == '' || data.answers[8].orignalans == null ? null : data.answers[8].ans + 0.03;
      var answer_4 = data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.04;
      var answer_5 = data.answers[6].orignalans == '' || data.answers[6].orignalans == null ? null : data.answers[6].ans + 0.05;
      var answer_6 = data.answers[10].orignalans == '' || data.answers[10].orignalans == null ? null : data.answers[10].ans + 0.06;
    
    let companyValueData = interpolateData([
      { x: 'PE', y: answer_1 },
      { x: 'OPE', y: answer_2 },
      { x: 'TE', y: answer_3 },
      { x: 'PW', y: answer_4 },
      { x: 'OPW', y: answer_5 },
      { x: 'TW', y: answer_6 }
    ]);

    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    const seriesDataTwentTwo = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
              { x: 'PE', y: [data.company_data[0].maximum, data.company_data[0].minimum] },
              { x: 'OPE', y: [data.company_data[4].maximum, data.company_data[4].minimum] },
              { x: 'TE', y: [data.company_data[8].maximum, data.company_data[8].minimum] },
              { x: 'PW', y: [data.company_data[2].maximum, data.company_data[2].minimum] },
              { x: 'OPW', y: [data.company_data[6].maximum, data.company_data[6].minimum] },
              { x: 'TW', y: [data.company_data[10].maximum, data.company_data[10].minimum] }
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
              { x: 'PE', y: data.company_data[0].average + 0.01 },
              { x: 'OPE', y: data.company_data[4].average + 0.02 },
              { x: 'TE', y: data.company_data[8].average + 0.03 },
              { x: 'PW', y: data.company_data[2].average + 0.04 },
              { x: 'OPW', y: data.company_data[6].average + 0.05 },
              { x: 'TW', y: data.company_data[10].average + 0.06 }
            ]
        },
        {
          name: 'Company Value',
          type: 'line',
          color: '#FF662B',
          data: companyValueData.data
        }
    ];
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb22_button1', 'pb22_button2', 'pb22_button3', 'pb22_button4', 'pb22_button5', 'pb22_button6'];
      const indices = [0, 4, 8, 2, 6, 10];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer == 100) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          }else{
            if (originalAnswer > average) {
              $button.removeClass('grey-hexagon').addClass('green-hexagon');
            } else if (originalAnswer < average) {
              $button.removeClass('grey-hexagon').addClass('red-hexagon');
            } else if (originalAnswer == average) {
              $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
            }
          }
        }
      });
    } else {
      $('.pb22_commonclass').addClass('grey-hexagon');
    }
   }
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
    if(industryStatus == 'default'){
      renderAvgChart("#chartpb-22-1", seriesDataTwentTwo, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of individuals trained', false, 300, 100, 10, customYaxisLabels, discreteMarkers);
    }else {
      renderAvgChart("#chartpb-22-2", seriesDataTwentTwo, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of individuals trained', false, 300, 100, 10, customYaxisLabels, discreteMarkers);
    }
    
    
 }

 function chartTwentyThree(data) {
  const categories = [
      'Perm Emp',
      'Other Perm Emp',
      'Total Emp',
      'Perm Work',
      'Other Perm Work',
      'Total Work'
  ];
  
    var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
    var answer_2 = data.answers[4].orignalans == '' || data.answers[4].orignalans == null ? null : data.answers[4].ans + 0.02;
    var answer_3 = data.answers[8].orignalans == '' || data.answers[8].orignalans == null ? null : data.answers[8].ans + 0.03;
    var answer_4 = data.answers[12].orignalans == '' || data.answers[12].orignalans == null ? null : data.answers[12].ans + 0.04;
    var answer_5 = data.answers[16].orignalans == '' || data.answers[16].orignalans == null ? null : data.answers[16].ans + 0.05;
    var answer_6 = data.answers[20].orignalans == '' || data.answers[20].orignalans == null ? null : data.answers[20].ans + 0.06;
  
  let companyValueData_1 = interpolateData([
    { x: 'PM', y: answer_1 },
    { x: 'PF', y: answer_2 },
    { x: 'PT', y: answer_3 },
    { x: 'OPM', y: answer_4 },
    { x: 'OPF', y: answer_5 },
    { x: 'OPT', y: answer_6 }
  ]);

  let discreteMarkers_1 = [
    ...companyValueData_1.nullIndices.map(index => ({
      seriesIndex: 2, // 'Company Value' series index
      dataPointIndex: index,
      size: 4, // Size for marker representing null values
      fillColor: '#808080', // Grey color for null value marker
      strokeColor: '#808080' // Grey border for null value marker
    }))
  ];
  
    var answer_7= data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.07;
    var answer_8 = data.answers[6].orignalans == '' || data.answers[6].orignalans == null ? null : data.answers[6].ans + 0.08;
    var answer_9 = data.answers[10].orignalans == '' || data.answers[10].orignalans == null ? null : data.answers[10].ans + 0.09;
    var answer_10 = data.answers[14].orignalans == '' || data.answers[14].orignalans == null ? null : data.answers[14].ans + 0.10;
    var answer_11 = data.answers[18].orignalans == '' || data.answers[18].orignalans == null ? null : data.answers[18].ans + 0.11;
    var answer_12 = data.answers[22].orignalans == '' || data.answers[22].orignalans == null ? null : data.answers[22].ans + 0.12;
  
  let companyValueData_2 = interpolateData([
    { x: 'PM', y: answer_7 },
    { x: 'PF', y: answer_8 },
    { x: 'PT', y: answer_9 },
    { x: 'OPM', y: answer_10 },
    { x: 'OPF', y: answer_11 },
    { x: 'OPT', y: answer_12 },
  ]);

  let discreteMarkers_2 = [
    ...companyValueData_2.nullIndices.map(index => ({
      seriesIndex: 2, // 'Company Value' series index
      dataPointIndex: index,
      size: 4, // Size for marker representing null values
      fillColor: '#808080', // Grey color for null value marker
      strokeColor: '#808080' // Grey border for null value marker
    }))
  ];
  const seriesDataTwentTwo = [
      {
          name: 'Max & Min',
          type: 'rangeBar',
          color: '#B7D93D',
          data: [
            { x: 'PM', y: [data.company_data[0].maximum, data.company_data[0].minimum] },
            { x: 'PF', y: [data.company_data[4].maximum, data.company_data[4].minimum] },
            { x: 'PT', y: [data.company_data[8].maximum, data.company_data[8].minimum] },
            { x: 'OPM', y: [data.company_data[12].maximum, data.company_data[12].minimum] },
            { x: 'OPF', y: [data.company_data[16].maximum, data.company_data[16].minimum] },
            { x: 'OPT', y: [data.company_data[20].maximum, data.company_data[20].minimum] }
          ]
      },
      {
          name: 'Avg Value',
          color: '#00D4E1',
          type: 'line',
          data: [
            { x: 'PM', y: [data.company_data[0].average + 0.01] },
            { x: 'PF', y: [data.company_data[4].average + 0.02] },
            { x: 'PT', y: [data.company_data[8].average + 0.03] },
            { x: 'OPM', y: [data.company_data[12].average + 0.04] },
            { x: 'OPF', y: [data.company_data[16].average + 0.05] },
            { x: 'OPT', y: [data.company_data[20].average + 0.06] }
          ]
      },
      {
        name: 'Company Value',
        type: 'line',
        color: '#FF662B',
        data:  companyValueData_1.data
      }
  ];

  const seriesDataTwentTwoWorkers = [
    {
        name: 'Max & Min',
        type: 'rangeBar',
        color: '#B7D93D',
        data: [
          { x: 'PM', y: [data.company_data[2].maximum, data.company_data[2].minimum] },
          { x: 'PF', y: [data.company_data[6].maximum, data.company_data[6].minimum] },
          { x: 'PT', y: [data.company_data[10].maximum, data.company_data[10].minimum] },
          { x: 'OPM', y: [data.company_data[14].maximum, data.company_data[14].minimum] },
          { x: 'OPF', y: [data.company_data[18].maximum, data.company_data[18].minimum] },
          { x: 'OPT', y: [data.company_data[22].maximum, data.company_data[22].minimum] },
        ]
    },
    {
        name: 'Avg Value',
        color: '#00D4E1',
        type: 'line',
        data: [
          { x: 'PM', y: [data.company_data[2].average + 0.07] },
          { x: 'PF', y: [data.company_data[6].average + 0.08] },
          { x: 'PT', y: [data.company_data[10].average + 0.09] },
          { x: 'OPM', y: [data.company_data[14].average + 0.10] },
          { x: 'OPF', y: [data.company_data[18].average + 0.11] },
          { x: 'OPT', y: [data.company_data[22].average + 0.12] },
        ]
    },
    {
      name: 'Company Value',
      type: 'line',
      color: '#FF662B',
      data: companyValueData_2.data
    }
];
  if (data.answers[0].checkbox_name == 'information_available') {
    const buttonClasses = ['pb23_button1', 'pb23_button2', 'pb23_button3', 'pb23_button4', 'pb23_button5', 'pb23_button6', 'pb23_button7', 'pb23_button8', 'pb23_button9', 'pb23_button10', 'pb23_button11', 'pb23_button12'];
    const indices = [0, 4, 8, 12, 16, 20, 2, 6, 10, 14, 18, 22];
    
    buttonClasses.forEach((buttonClass, idx) => {
      const answer = data.answers[indices[idx]].ans;
      const originalAnswer = data.answers[indices[idx]].orignalans;
      const average = data.company_data[indices[idx]].average;
      const $button = $(`.${buttonClass}`);
  
      $button.addClass('grey-hexagon');  // Set default class
  
      if (originalAnswer != '') {
        if (Number(originalAnswer) == 100) {
          $button.removeClass('grey-hexagon').addClass('green-hexagon');
        }else{
          if (originalAnswer > average) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (originalAnswer < average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (originalAnswer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }
      }
    });
  } else {
    $('.pb23_commonclass').addClass('grey-hexagon');
  }
  const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
  renderAvgChart("#chartpb-23-1", seriesDataTwentTwo, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of individuals', false, 300, 100, 10, customYaxisLabels, discreteMarkers_1);
  renderAvgChart("#chartpb-23-2", seriesDataTwentTwoWorkers, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of individuals', false, 300, 100, 10, customYaxisLabels, discreteMarkers_2);
}

  function chartTwentyFour(data) {
    const graphOneSeries = [
      convertPercentToNumber(data.company_data[0].average),
      convertPercentToNumber(data.company_data[0].maximum),
      convertPercentToNumber(data.company_data[0].minimum),
      convertPercentToNumber(data.company_data[1].average),
      convertPercentToNumber(data.company_data[1].maximum),
      convertPercentToNumber(data.company_data[1].minimum),
    ];

    const graphTwoSeries = [
      convertPercentToNumber(data.company_data[3].percentage)
    ];

  
      var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01;
      var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;

    let companyValueData = interpolateData([
      { x: ""+currentYear+"", y: answer_1 },
      { x: ""+previousYear+"", y: answer_2 }
    ]);
  
    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];
    if (graphOneSeries.every(value => value === 0)) {
      $('#chartpb-24-1').text('No data available to show the chart');
      $('#chartpb-24-1').css('font-size',"11px");
      $('#chartpb-24-1').css('margin-top', '-20px');
      $('#chartpb-24-1').css('margin-left',"76px");
      $('.labelclass-21').hide();
    } else {
      const categories = [
        ""+currentYear+"",
        ""+previousYear+""
      ];
      const seriesDataOne = [
          {
              name: 'Max & Min',
              type: 'rangeBar',
              color: '#B7D93D',
              data: [
                  { x: ""+currentYear+"", y: [data.company_data[0].maximum, data.company_data[0].minimum] },
                  { x: ""+previousYear+"", y: [data.company_data[1].maximum, data.company_data[1].minimum] }
              ]
          },
          {
              name: 'Avg Value',
              color: '#00D4E1',
              type: 'line',
              data: [
                  { x: ""+currentYear+"", y: data.company_data[0].average + 0.01 },
                  { x: ""+previousYear+"", y: data.company_data[1].average + 0.02 }
              ]
          },
          {
              name: 'Company Value',
              type: 'line',
              color: '#FF662B',
              data: companyValueData.data
          }
      ];
      const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
      renderAvgChart("#chartpb-24-1", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of total wage', false, 300, 100, 5, customYaxisLabels, discreteMarkers);
    }

    if (graphTwoSeries.every(value => value === 0)) {
      $('#chartpb-24-2').text('No data available to show the chart');
      $('#chartpb-24-2').css('font-size',"11px");
      $('#chartpb-24-2').css('margin-left',"225px");
      $('#pb-24-2-heading').css('margin-left',"52px");
      $('#chartpb-24-2').css('width',"300px");
      $('.pb-24-2-legend').hide()
    } else {
      renderRadialBarChart("#chartpb-24-2", [convertPercentToNumber(data.company_data[3].percentage)], ['Percentage'], '#B7D93D');
    }

  }

  function TwentyFive(data) {
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb25_button1', 'pb25_button2', 'pb25_button3', 'pb25_button4', 'pb25_button5', 'pb25_button6'];
      const indices = [0, 1, 2, 3, 4, 5];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const $button = $(`.${buttonClass}`);
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if (answer == 0) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else{
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } 
        }
      });
    } else {
      $('.pb25_commonclass').addClass('grey-hexagon');
    }
  }

  function chartTwentySix(data) {
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name == 'information_available') {
      if (data.answers[0].ans == 'Yes, it does') {
        $('.pb26_button1').addClass('green-hexagon');
      }else {
        $('.pb26_button1').addClass('red-hexagon');
      }
    } else {
      $('.pb26_commonclass').addClass('grey-hexagon');
    }
    }
    if(industryStatus == 'default'){
      renderConditionalPieChart(data, '#chartpb-26-1', ['% of companies that have integrated', '% of companies that have not integrated'], 520, ['#150E40', '#B7D93D'], true);
    }else {
      renderConditionalPieChart(data, '#chartpb-26-2', ['% of companies that have integrated', '% of companies that have not integrated'], 520, ['#150E40', '#B7D93D'], true);
    }
  }

  function chartTwentySeven(data) {
    const categories = [
        'Child labour',
        'Forced labour',
        'Sexual harassment',
        'Discrimination',
        'Wages',
        'Others'
    ];


      var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01 ;
      var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;
      var answer_3 = data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.03;
      var answer_4 = data.answers[3].orignalans == '' || data.answers[3].orignalans == null ? null : data.answers[3].ans + 0.04;
      var answer_5 = data.answers[4].orignalans == '' || data.answers[4].orignalans == null ? null : data.answers[4].ans + 0.05;
     
    let companyValueData = interpolateData([
      { x: 'Child labour', y: answer_1 },
      { x: 'Forced labour', y: answer_2 },
      { x: 'Sexual harassment', y: answer_3 },
      { x: 'Discrimination', y: answer_4},
      { x: 'Wages', y: answer_5},
    ]);
  
    let discreteMarkers = [
      ...companyValueData.nullIndices.map(index => ({
        seriesIndex: 2, // 'Company Value' series index
        dataPointIndex: index,
        size: 4, // Size for marker representing null values
        fillColor: '#808080', // Grey color for null value marker
        strokeColor: '#808080' // Grey border for null value marker
      }))
    ];

    const seriesDataTwentSeven = [
        {
            name: 'Max & Min',
            type: 'rangeBar',
            color: '#B7D93D',
            data: [
              { x: 'Child labour', y: [data.company_data[0].maximum, data.company_data[0].minimum] },
              { x: 'Forced labour', y: [data.company_data[1].maximum, data.company_data[1].minimum] },
              { x: 'Sexual harassment', y: [data.company_data[2].maximum, data.company_data[2].minimum] },
              { x: 'Discrimination', y: [data.company_data[3].maximum, data.company_data[3].minimum] },
              { x: 'Wages', y: [data.company_data[4].maximum, data.company_data[4].minimum] },
            ]
        },
        {
            name: 'Avg Value',
            color: '#00D4E1',
            type: 'line',
            data: [
              { x: 'Child labour', y: data.company_data[0].average + 0.01 },
              { x: 'Forced labour', y: data.company_data[1].average + 0.02 },
              { x: 'Sexual harassment', y: data.company_data[2].average + 0.03 },
              { x: 'Discrimination', y: data.company_data[3].average + 0.04 },
              { x: 'Wages', y: data.company_data[4].average + 0.05 },
            ]
        },
        {
          name: 'Company Value',
          type: 'line',
          color: '#FF662B',
          data: companyValueData.data
        }
    ];
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb27_button1', 'pb27_button2', 'pb27_button3', 'pb27_button4', 'pb27_button5'];
      const indices = [0, 1, 2, 3, 4];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer == 100) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else {
            if (originalAnswer > average) {
              $button.removeClass('grey-hexagon').addClass('green-hexagon');
            } else if (originalAnswer < average) {
              $button.removeClass('grey-hexagon').addClass('red-hexagon');
            } else if (originalAnswer == average) {
              $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
            }
          }
        }
      });
    } else {
      $('.pb27_commonclass').addClass('grey-hexagon');
    }
    }
    const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100']; 
    if(industryStatus == 'default'){
      renderAvgChart("#chartpb-27-1", seriesDataTwentSeven, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of operations', false, 500, 100, 10, customYaxisLabels, discreteMarkers);
    }else {
      renderAvgChart("#chartpb-27-2", seriesDataTwentSeven, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of operations', false, 500, 100, 10, customYaxisLabels, discreteMarkers);
    }
 }

 function creatingDataButtons(data, id) {
   if(id == 'PB-28') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const answer = data.answers[0].ans;
      const originalAnswer = data.answers[0].orignalans;
      const average = data.company_data[0].average;
      $('.pb28_button1').addClass('grey-hexagon');
      if (originalAnswer != '') {
        if (originalAnswer < average) {
          $('.pb28_button1').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (originalAnswer > average) {
          $('.pb28_button1').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (originalAnswer == average) {
          $('.pb28_button1').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }

      if (data.answers[3].ans) {
        $('.pb28_button2').removeClass('grey-hexagon').addClass('green-hexagon');
      }else {
        $('.pb28_button2').removeClass('grey-hexagon').addClass('red-hexagon');
      }
    }else {
      $('.pb28_commonclass').addClass('grey-hexagon');
    }
    renderCircleChart("#chartpb-28-1", [convertPercentToNumber(data.company_data[3].percentage.percent_option_1), convertPercentToNumber(data.company_data[3].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
   }

   if(id == 'PB-29') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const answer = data.answers[0].ans;
      const originalAnswer = data.answers[0].orignalans;
      const average = data.company_data[0].average;
      $('.pb29_button1').addClass('grey-hexagon');
      if (originalAnswer != '') {
        if (originalAnswer < average) {
          $('.pb29_button1').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (originalAnswer > average) {
          $('.pb29_button1').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (originalAnswer == average) {
          $('.pb29_button1').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }

      if (data.answers[3].ans) {
        $('.pb29_button2').removeClass('grey-hexagon').addClass('green-hexagon');
      }else {
        $('.pb29_button2').removeClass('grey-hexagon').addClass('red-hexagon');
      }
    }else {
      $('.pb29_commonclass').addClass('grey-hexagon');
    }
    renderCircleChart("#chartpb-29-1", [convertPercentToNumber(data.company_data[3].percentage.percent_option_1), convertPercentToNumber(data.company_data[3].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
   }

   if(id == 'PB-30') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const answer = data.answers[0].ans;
      const originalAnswer = data.answers[0].orignalans;
      const average = data.company_data[0].average;
      $('.pb30_button1').addClass('grey-hexagon');
      if (originalAnswer != '') {
        if (originalAnswer < average) {
          $('.pb30_button1').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (originalAnswer > average) {
          $('.pb30_button1').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (originalAnswer == average) {
          $('.pb30_button1').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }

      if (data.answers[3].ans) {
        $('.pb30_button2').removeClass('grey-hexagon').addClass('green-hexagon');
      }else {
        $('.pb30_button2').removeClass('grey-hexagon').addClass('red-hexagon');
      }
    }else {
      $('.pb30_commonclass').addClass('grey-hexagon');
    }
    renderCircleChart("#chartpb-30-1", [convertPercentToNumber(data.company_data[3].percentage.percent_option_1), convertPercentToNumber(data.company_data[3].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
   }

   if(id == 'PB-31') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const answer = data.answers[0].ans;
      const originalAnswer = data.answers[0].orignalans;
      const average = data.company_data[0].average;
      $('.pb31_button1').addClass('grey-hexagon');
      if (originalAnswer != '') {
        if (originalAnswer < average) {
          $('.pb31_button1').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (originalAnswer > average) {
          $('.pb31_button1').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (originalAnswer == average) {
          $('.pb31_button1').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }

      if (data.answers[3].ans) {
        $('.pb31_button2').removeClass('grey-hexagon').addClass('green-hexagon');
      }else {
        $('.pb31_button2').removeClass('grey-hexagon').addClass('red-hexagon');
      }
    }else {
      $('.pb31_commonclass').addClass('grey-hexagon');
    }
    renderCircleChart("#chartpb-31-1", [convertPercentToNumber(data.company_data[3].percentage.percent_option_1), convertPercentToNumber(data.company_data[3].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
   }

   if(id == 'PB-32') {
    if (data.answers[0].checkbox_name == 'information_available') {
      const answer = data.answers[0].ans;
      const originalAnswer = data.answers[0].orignalans;
      const average = data.company_data[0].average;
      $('.pb32_button1').addClass('grey-hexagon');
      if (originalAnswer != '') {
        if (originalAnswer > average) {
          $('.pb32_button1').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (originalAnswer < average) {
          $('.pb32_button1').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (originalAnswer == average) {
          $('.pb32_button1').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }

      const answer2 = data.answers[2].ans;
      const average2 = data.company_data[2].average;
      const orignalans2 = data.answers[2].orignalans;
      $('.pb32_button3').addClass('grey-hexagon');
      if (orignalans2 != '') {
        if (orignalans2 > average2) {
          $('.pb32_button3').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (orignalans2 < average2) {
          $('.pb32_button3').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (orignalans2 == average2) {
          $('.pb32_button3').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }
      $('.pb32_button4').addClass(data.answers[4].ans ? 'green-hexagon' : 'red-hexagon');
      //$('.pb32_button4').addClass(data.answers[5].ans ? 'green-hexagon' : 'red-hexagon');
    }else {
      $('.pb32_commonclass').addClass('grey-hexagon');
    }
    renderAdditionalBarChartThirtyTwo("#chartpb-32-1", data, ['% of input material by value'], ['DSP', 'DWI']);
    renderCircleChart("#chartpb-32-2", [convertPercentToNumber(data.company_data[4].percentage.percent_option_1), convertPercentToNumber(data.company_data[4].percentage.percent_option_2)], ['Percentage'], ['#150E40', '#B7D93D']);
   }

   if(id == 'PB-33') {
    renderAdditionalBarChart("#chartpb-33", data, ['% of input sourced'], ['']);
    if (data.answers[0].checkbox_name == 'information_available') {
      const answer = data.answers[0].ans;
      const originalAnswer = data.answers[0].orignalans;
      const average = convertPercentToNumber(data.percentage[0].values.average);
      $('.pb33_button1').addClass('grey-hexagon');
      if (originalAnswer != '') {
        if (originalAnswer > average) {
          $('.pb33_button1').removeClass('grey-hexagon').addClass('green-hexagon');
        } else if (originalAnswer < average) {
          $('.pb33_button1').removeClass('grey-hexagon').addClass('red-hexagon');
        } else if (originalAnswer == average) {
          $('.pb33_button1').removeClass('grey-hexagon').addClass('yellow-hexagon');
        }
      }
    }else {
      $('.pb33_commonclass').addClass('grey-hexagon');
    }
   }

 }

  function chartThirtyFour(data) {
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb34_button1', 'pb34_button2', 'pb34_button3'];
      const indices = [0, 1, 2];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
        if (originalAnswer != '') {
          if (originalAnswer > average) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (originalAnswer < average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (originalAnswer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }        
      });

    } else {
      $('.pb34_commonclass').addClass('grey-hexagon');
    }
      const categories = [
        "Environmental",
        "Usage related",
        "Recycling"
      ];
      
        var answer_1= data.answers[0].orignalans == '' || data.answers[0].orignalans == null ? null : data.answers[0].ans + 0.01 ;
        var answer_2 = data.answers[1].orignalans == '' || data.answers[1].orignalans == null ? null : data.answers[1].ans + 0.02;
        var answer_3 = data.answers[2].orignalans == '' || data.answers[2].orignalans == null ? null : data.answers[2].ans + 0.03;
      
      let companyValueData = interpolateData([
        { x: "Environmental", y: answer_1 },
        { x: "Usage related", y: answer_2 },
        { x: "Recycling", y: answer_3 }
      ]);
    
      let discreteMarkers = [
        ...companyValueData.nullIndices.map(index => ({
          seriesIndex: 2, // 'Company Value' series index
          dataPointIndex: index,
          size: 4, // Size for marker representing null values
          fillColor: '#808080', // Grey color for null value marker
          strokeColor: '#808080' // Grey border for null value marker
        }))
      ];
      const seriesDataOne = [
          {
              name: 'Max & Min',
              type: 'rangeBar',
              color: '#B7D93D',
              data: [
                  { x: "Environmental", y: [data.company_data[0].maximum, data.company_data[0].minimum] },
                  { x: "Usage related", y: [data.company_data[1].maximum, data.company_data[1].minimum] },
                  { x: "Recycling", y: [data.company_data[2].maximum, data.company_data[2].minimum] }
              ]
          },
          {
              name: 'Avg Value',
              color: '#00D4E1',
              type: 'line',
              data: [
                  { x: "Environmental", y: data.company_data[0].average + 0.01 },
                  { x: "Usage related", y: data.company_data[1].average + 0.02 },
                  { x: "Recycling", y: data.company_data[2].average + 0.03}
              ]
          },
          {
              name: 'Company Value',
              type: 'line',
              color: '#FF662B',
              data: companyValueData.data
          }
      ];
      const customYaxisLabels = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'];
      renderAvgChart("#chartpb-34", seriesDataOne, '', categories, ['Max & Min', 'Avg Value', 'Company Value'], '% of turnover', false, 300, 100, 5, customYaxisLabels, discreteMarkers);
    //renderrConditionalBarChart(data, '#chartpb-34', ['Environmental and Social Parameters Relevant to the Product', 'Safe and Responsible Usage', 'Recycling']);
  }
  function chartThirtyFive(data) {
    

    const answerClasses = {
      'Internal Policy': 'yellow-hexagon',
      'Publicly available Policy': 'green-hexagon',
      'Company reported to have no such policy': 'red-hexagon'
    };
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
      const $button = $('.pb35_button1');
      $button.addClass('grey-hexagon');  // Set default class
    if (data.answers[0].checkbox_name === 'information_available') {
      const hexagonClass = answerClasses[data.answers[0].ans];
      if (hexagonClass) {
        $button.removeClass('grey-hexagon').addClass(hexagonClass);
      }
    } else {
      $('.pb35_commonclass').addClass('grey-hexagon');
    }
    }
    if(industryStatus == 'default'){
      renderConditionalPieChart(data, '#chartpb-35-1', ['% of companies with internally policy', '% of companies with publicly available policy', '% of companies with no policy'], 540, ['#150E40', '#B7D93D', '#00D4E1'], true);
    }else {
      renderConditionalPieChart(data, '#chartpb-35-2', ['% of companies with internally policy', '% of companies with publicly available policy', '% of companies with no policy'], 540, ['#150E40', '#B7D93D', '#00D4E1'], true);
    }
  }
  //--------------------------------Chart Code Starts-----------------------------
  function createTableChart(data) {
    
    const averageMale = [Math.round(data.company_data[0].average), Math.round(data.company_data[1].average), Math.round(data.company_data[2].average)];
    const averageFemale = [Math.round(data.company_data[3].average), Math.round(data.company_data[4].average), Math.round(data.company_data[5].average)];
    const averageTotal = [Math.round(data.company_data[6].average), Math.round(data.company_data[7].average), Math.round(data.company_data[8].average)];
    const companyAverageMale = [Math.round(data.answers[0].ans + 0.01), Math.round(data.answers[1].ans + 0.02), Math.round(data.answers[2].ans + 0.03)];
    const companyAverageFemale = [Math.round(data.answers[3].ans + 0.04), Math.round(data.answers[4].ans + 0.05), Math.round(data.answers[5].ans + 0.06)];
    const companyAverageTotal = [Math.round(data.answers[6].ans + 0.07), Math.round(data.answers[7].ans + 0.08), Math.round(data.answers[8].ans + 0.09)];

    const averageWorkersMale = [Math.round(data.company_data[9].average), Math.round(data.company_data[10].average), Math.round(data.company_data[11].average)];
    const averageWorkersFemale = [Math.round(data.company_data[12].average), Math.round(data.company_data[13].average), Math.round(data.company_data[14].average)];
    const averageWorkersTotal = [Math.round(data.company_data[15].average), Math.round(data.company_data[16].average), Math.round(data.company_data[17].average)];
    const companyWorkersAverageMale = [Math.round(data.answers[9].ans + 0.01), Math.round(data.answers[10].ans + 0.02), Math.round(data.answers[11].ans + 0.03)];
    const companyWorkersAverageFemale = [Math.round(data.answers[12].ans + 0.04), Math.round(data.answers[13].ans + 0.05), Math.round(data.answers[14].ans + 0.06)];
    const companyWorkersAverageTotal = [Math.round(data.answers[15].ans + 0.07), Math.round(data.answers[16].ans + 0.08), Math.round(data.answers[17].ans + 0.09)];
  
     
    if (data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb4_button1', 'pb4_button2', 'pb4_button3', 'pb4_button4', 'pb4_button5', 'pb4_button6'];
      const indices = [0, 3, 6, 9, 12, 15];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const originalAnswer = data.answers[indices[idx]].orignalans;
        const average = data.company_data[indices[idx]].average;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (originalAnswer != '') {
          if (originalAnswer < average) {
            $button.removeClass('grey-hexagon').addClass('green-hexagon');
          } else if (originalAnswer > average) {
            $button.removeClass('grey-hexagon').addClass('red-hexagon');
          } else if (originalAnswer == average) {
            $button.removeClass('grey-hexagon').addClass('yellow-hexagon');
          }
        }
      });
    } else {
      $('.pb4_commonclass').addClass('grey-hexagon');
    }
    const minValue = 3;
    const average_Male = averageMale.map(value => value === 0 ? minValue : value);
    const average_Female = averageFemale.map(value => value === 0 ? minValue : value);
    const average_Total = averageTotal.map(value => value === 0 ? minValue : value);
    const averageWorkers_Male = averageWorkersMale.map(value => value === 0 ? minValue : value);
    const averageWorkers_Female = averageWorkersFemale.map(value => value === 0 ? minValue : value);
    const averageWorkers_Total = averageWorkersTotal.map(value => value === 0 ? minValue : value);
    renderBarChartVerticalEmp("#chartpb-04-1", data, currentYear, previousYear, currentYear-2);
    renderBarChartVerticalWork("#chartpb-04-2", data, currentYear, previousYear, currentYear-2);
    //renderLineChart("#chartpb-04-1", averageMale, averageFemale, averageTotal, companyAverageMale, companyAverageFemale, companyAverageTotal, [currentYear, previousYear, currentYear-2], '');
    //renderLineChart("#chartpb-04-2", averageWorkersMale, averageWorkersFemale, averageWorkersTotal, companyWorkersAverageMale, companyWorkersAverageFemale, companyWorkersAverageTotal, [currentYear, previousYear, currentYear-2], '');
  }

  function renderBarChartVerticalEmp(container, data, currentYear, previousYear, twoyearsBefore) {
    const years = [
        "" + currentYear + "", "" + previousYear + "", "" + twoyearsBefore + ""
    ];

    if (data.answers[0].orignalans == '' || data.answers[0].checkbox_name == 'No information' )  {
      var answer1Color = '#150E40';
      var value_1 = '';
    }else {
      var answer1Color = '#FF4560';
      var value_1 = Math.round(data.answers[0].ans);
    }
    if (data.answers[1].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer2Color = '#B7D93D';
      var value_2 = '';
    }else {
      var answer2Color = '#FF4560';
      var value_2 = Math.round(data.answers[1].ans);
    }
    if (data.answers[2].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer3Color = '#00D4E1';
      var value_3 = '';
    }else {
      var answer3Color = '#FF4560';
      var value_3 = Math.round(data.answers[2].ans);
    }
    if (data.answers[3].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer4Color = '#150E40';
      var value_4 = '';
    }else {
      var answer4Color = '#FF4560';
      var value_4 = Math.round(data.answers[3].ans);
    }
    if (data.answers[4].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer5Color = '#B7D93D';
      var value_5 = '';
    }else {
      var answer5Color = '#FF4560';
      var value_5 = Math.round(data.answers[4].ans);
    }
    if (data.answers[5].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer6Color = '#00D4E1';
      var value_6 = '';
    }else {
      var answer6Color = '#FF4560';
      var value_6 = Math.round(data.answers[5].ans);
    }
    if (data.answers[6].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer7Color = '#150E40';
      var value_7 = '';
    }else {
      var answer7Color = '#FF4560';
      var value_7 = Math.round(data.answers[6].ans);
    }
    if (data.answers[7].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer8Color = '#B7D93D';
      var value_8 = '';
    }else {
      var answer8Color = '#FF4560';
      var value_8 = Math.round(data.answers[7].ans);
    }
    if (data.answers[8].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
      var answer9Color = '#00D4E1';
      var value_9 = '';
    }else {
      var answer9Color = '#FF4560';
      var value_9 = Math.round(data.answers[8].ans);
    }

    const options = {
        series: [
            {
                name: '2024',
                data: [
                    {
                        x: 'Male',
                        y: Math.round(data.company_data[0].average),
                        goals: [
                            {
                                name: 'Expected',
                                value: value_1,
                                strokeHeight: 5,
                                strokeColor: answer1Color
                            }
                        ]
                    },
                    {
                        x: 'Female',
                        y: Math.round(data.company_data[3].average),
                        goals: [
                            {
                                name: 'Target',
                                value: value_4,
                                strokeHeight: 5,
                                strokeColor: answer4Color
                            }
                        ]
                    },
                    {
                        x: 'Total',
                        y: Math.round(data.company_data[6].average),
                        goals: [
                            {
                                name: 'Target',
                                value: value_7,
                                strokeHeight: 5,
                                strokeColor: answer7Color
                            }
                        ]
                    }
                ]
            },
            {
                name: years[1],
                data: [
                    {
                        x: 'Male',
                        y: Math.round(data.company_data[1].average),
                        goals: [
                            {
                                name: 'Expected',
                                value: value_2,
                                strokeHeight: 5,
                                strokeColor: answer2Color
                            }
                        ]
                    },
                    {
                        x: 'Female',
                        y: Math.round(data.company_data[4].average),
                        goals: [
                            {
                                name: 'Target',
                                value: value_5,
                                strokeHeight: 5,
                                strokeColor: answer5Color
                            }
                        ]
                    },
                    {
                        x: 'Total',
                        y: Math.round(data.company_data[7].average),
                        goals: [
                            {
                                name: 'Target',
                                value: value_8,
                                strokeHeight: 5,
                                strokeColor: answer8Color
                            }
                        ]
                    }
                ]
            },
            {
                name: years[2],
                data: [
                    {
                        x: 'Male',
                        y: Math.round(data.company_data[2].average),
                        goals: [
                            {
                                name: 'Expected',
                                value: value_3,
                                strokeHeight: 5,
                                strokeColor: answer3Color
                            }
                        ]
                    },
                    {
                        x: 'Female',
                        y: Math.round(data.company_data[5].average),
                        goals: [
                            {
                                name: 'Target',
                                value: value_6,
                                strokeHeight: 5,
                                strokeColor: answer6Color
                            }
                        ]
                    },
                    {
                        x: 'Total',
                        y: Math.round(data.company_data[8].average),
                        goals: [
                            {
                                name: 'Target',
                                value: value_9,
                                strokeHeight: 5,
                                strokeColor: answer9Color
                            }
                        ]
                    }
                ]
            }
        ],
        chart: {
            height: 300,
            width:265,
            type: 'bar',
            toolbar: {
                show: false
            }
        },
        plotOptions: {
            bar: {
                columnWidth: '60%'
            }
        },
        colors: ['#150E40', '#B7D93D', '#00D4E1'],
        dataLabels: {
            enabled: false
        },
        yaxis: {
            min: 0,
            max: 50,
            tickAmount: 10
        },
        xaxis: {
            categories: ['Male', 'Female', 'Total']
        },
        legend: {
            show: false,
            showForSingleSeries: true,
            customLegendItems: [years[0], years[1], years[2], 'Company data'],
            markers: {
              fillColors: ['#150E40', '#B7D93D', '#00D4E1', '#FF4560']
            }
        }
    };

    new ApexCharts(document.querySelector(container), options).render();
}

function renderBarChartVerticalWork(container, data, currentYear, previousYear, twoyearsBefore) {
  const years = [
      "" + currentYear + "", "" + previousYear + "", "" + twoyearsBefore + ""
  ];

  if (data.answers[9].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer1Color = '#150E40';
    var value_1 = '';
  }else {
    var answer1Color = '#FF4560';
    var value_1 = Math.round(data.answers[9].ans);
  }
  if (data.answers[10].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer2Color = '#B7D93D';
    var value_2 = '';
  }else {
    var answer2Color = '#FF4560';
    var value_2 = Math.round(data.answers[10].ans);
  }
  if (data.answers[11].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer3Color = '#00D4E1';
    var value_3 = '';
  }else {
    var answer3Color = '#FF4560';
    var value_3 = Math.round(data.answers[11].ans);
  }
  if (data.answers[12].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer4Color = '#150E40';
    var value_4 = '';
  }else {
    var answer4Color = '#FF4560';
    var value_4 = Math.round(data.answers[12].ans);
  }
  if (data.answers[13].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer5Color = '#B7D93D';
    var value_5 = '';
  }else {
    var answer5Color = '#FF4560';
    var value_5 = Math.round(data.answers[13].ans);
  }
  if (data.answers[14].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer6Color = '#00D4E1';
    var value_6 = '';
  }else {
    var answer6Color = '#FF4560';
    var value_6 = Math.round(data.answers[14].ans);
  }
  if (data.answers[15].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer7Color = '#150E40';
    var value_7 = '';
  }else {
    var answer7Color = '#FF4560';
    var value_7 = Math.round(data.answers[15].ans);
  }
  if (data.answers[16].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer8Color = '#B7D93D';
    var value_8 = '';
  }else {
    var answer8Color = '#FF4560';
    var value_8 = Math.round(data.answers[16].ans);
  }
  if (data.answers[17].orignalans == '' || data.answers[0].checkbox_name == 'No information')  {
    var answer9Color = '#00D4E1';
    var value_9 = '';
  }else {
    var answer9Color = '#FF4560';
    var value_9 = Math.round(data.answers[17].ans);
  }
  const options = {
      series: [
          {
              name: years[0],
              data: [
                  {
                      x: 'Male',
                      y: Math.round(data.company_data[9].average),
                      goals: [
                          {
                              name: 'Expected',
                              value: value_1,
                              strokeHeight: 5,
                              strokeColor: answer1Color
                          }
                      ]
                  },
                  {
                      x: 'Female',
                      y: Math.round(data.company_data[12].average),
                      goals: [
                          {
                              name: 'Target',
                              value: value_4,
                              strokeHeight: 5,
                              strokeColor: answer4Color
                          }
                      ]
                  },
                  {
                      x: 'Total',
                      y: Math.round(data.company_data[15].average),
                      goals: [
                          {
                              name: 'Target',
                              value: value_7,
                              strokeHeight: 5,
                              strokeColor: answer7Color
                          }
                      ]
                  }
              ]
          },
          {
              name: years[1],
              data: [
                  {
                      x: 'Male',
                      y: Math.round(data.company_data[10].average),
                      goals: [
                          {
                              name: 'Expected',
                              value: value_2,
                              strokeHeight: 5,
                              strokeColor: answer2Color
                          }
                      ]
                  },
                  {
                      x: 'Female',
                      y: Math.round(data.company_data[13].average),
                      goals: [
                          {
                              name: 'Target',
                              value: value_5,
                              strokeHeight: 5,
                              strokeColor: answer5Color
                          }
                      ]
                  },
                  {
                      x: 'Total',
                      y: Math.round(data.company_data[16].average),
                      goals: [
                          {
                              name: 'Target',
                              value: value_8,
                              strokeHeight: 5,
                              strokeColor: answer8Color
                          }
                      ]
                  }
              ]
          },
          {
              name: years[2],
              data: [
                  {
                      x: 'Male',
                      y: Math.round(data.company_data[11].average),
                      goals: [
                          {
                              name: 'Expected',
                              value: value_3,
                              strokeHeight: 5,
                              strokeColor: answer3Color
                          }
                      ]
                  },
                  {
                      x: 'Female',
                      y: Math.round(data.company_data[14].average),
                      goals: [
                          {
                              name: 'Target',
                              value: value_6,
                              strokeHeight: 5,
                              strokeColor: answer6Color
                          }
                      ]
                  },
                  {
                      x: 'Total',
                      y: Math.round(data.company_data[17].average),
                      goals: [
                          {
                              name: 'Target',
                              value: value_9,
                              strokeHeight: 5,
                              strokeColor: answer9Color
                          }
                      ]
                  }
              ]
          }
      ],
      chart: {
          height: 300,
          width:265,
          type: 'bar',
          toolbar: {
              show: false
          }
      },
      plotOptions: {
          bar: {
              columnWidth: '60%'
          }
      },
      colors: ['#150E40', '#B7D93D', '#00D4E1'],
      dataLabels: {
          enabled: false
      },
      yaxis: {
          min: 0,
          max: 50,
          tickAmount: 10
      },
      xaxis: {
          categories: ['Male', 'Female', 'Total']
      },
      legend: {
          show: false,
          showForSingleSeries: true,
          customLegendItems: [years[0], years[1], years[2], 'Company data'],
          markers: {
            fillColors: ['#150E40', '#B7D93D', '#00D4E1', '#FF4560']
          }
      }
  };

  new ApexCharts(document.querySelector(container), options).render();
}

  function renderAvgChart(container, seriesData, title, categories, LegendItems, yaxistitle, legendStatus, width, maxValue, tickAmount, customYaxisLabels,discreteMarkers) {
    const options = {
        series: seriesData,
        chart: {
            height: 300,
            width: width,
            type: 'rangeBar',
            zoom: {
                enabled: false
            },
            toolbar: {
                show: false
            }
        },
        plotOptions: {
            bar: {
                isDumbbell: true,
                columnWidth: '1%',
                dumbbellColors: [
                    ['#454545', '#454545']
                ]
            }
        },
        stroke: {
            curve: 'smooth',
            width: 1
        },
        markers: {
            size: 6,
            discrete: discreteMarkers
        },
        legend: {
            show: legendStatus,
            position: 'top',
            horizontalAlign: 'left',
            customLegendItems: LegendItems,
            markers: {
                fillColors: ['#000']
            },
        },
        fill: {
            type: 'gradient',
            gradient: {
                type: 'vertical',
                gradientToColors: ['#00E396'],
                inverseColors: true,
                stops: [0, 100]
            }
        },
        grid: {
            xaxis: {
                lines: {
                    show: true
                }
            },
            yaxis: {
                lines: {
                    show: false
                }
            }
        },
        xaxis: {
            categories: categories,
            tickPlacement: 'on',
            labels: {
              style: {
                colors: '',
                fontSize: '9px'
              }
            }
        },
        yaxis: {
          min: 0,
          max: maxValue,
          tickAmount: customYaxisLabels.length - 1,
          labels: {
            formatter: function(value, index) {
                return customYaxisLabels[index] || '';
            }
          },
            title: {
              text: yaxistitle,
              rotate: -90,
              offsetX: 0,
              offsetY: 0,
              style: {
                color: undefined,
                fontSize: '12px',
                fontWeight: 600,
                cssClass: 'apexcharts-yaxis-title'
              }
            }
        },
        title: {
            text: title,
            align: 'center',
            style: {
              color: undefined,
              fontSize: '12px',
              //fontFamily: 'Calibri Light,sans-serif',
              fontWeight: 600,
              cssClass: 'apexcharts-yaxis-title'
            }
        },
        dataLabels: {
            enabled: false,
            formatter: function (val, opts) {
                return val instanceof Array ? val.join(' - ') : val;
            },
            style: {
                fontSize: '10px',
                colors: ['#8E44AD']
            }
        }
    };
    new ApexCharts(document.querySelector(container), options).render();
  }

  function interpolateData(data) {
    let prevValue = null;
    let nextValue = null;
    let nullIndices = [];
    let hasNull = false;
  
    for (let i = 0; i < data.length; i++) {
      if (data[i].y === null) {
        nullIndices.push(i);
        hasNull = true;
      } else {
        prevValue = data[i].y;
      }
    }
  
    for (let i = 0; i < data.length; i++) {
      if (data[i].y === null) {
        // Add small decimal values to ensure the line is drawn
        data[i].y = (i + 1) * 0.01;
      } else if (data[i].y !== null) {
        prevValue = data[i].y;
      }
    }
  
    // Set the button color to grey if there are null values
     
    return {
      data: data,
      nullIndices
    };
  }

  function createChart(data) {
    
    const chartData = [
      convertPercentToNumber(data.percentage[0].percentage),
      convertPercentToNumber(data.percentage[1].percentage),
      convertPercentToNumber(data.percentage[2].percentage),
      convertPercentToNumber(data.percentage[3].percentage),
      convertPercentToNumber(data.percentage[4].percentage)
    ];
    const minValue = 5;
    const chartData_dProcessed = chartData.map(value => value === 0 ? minValue : value);
    const options = {
      series: [{ 
        data: chartData_dProcessed 
      }],
      chart: { type: 'bar', height: 430,width: 430,toolbar: {
        show: false, // This will hide the toolbar
      } },
      plotOptions: { bar: { horizontal: true, dataLabels: { position: 'top' } } },
      dataLabels: {
        enabled: true,
        offsetX: -6,
        formatter: function (val, opts) {
          return chartData[opts.dataPointIndex]; // Show the original value from chartData
        },
        style: { fontSize: '12px', colors: ['#fff'] },
      },
      stroke: { show: true, width: 1, colors: ['#fff'] },
      tooltip: { shared: true, intersect: false },
      yaxis: { min: 0, max: 100,title: {
        text: '% of companies',
        rotate: -90,
        offsetX: 0,
        offsetY: 0,
        style: {
          color: undefined,
          fontSize: '12px',
          //fontFamily: 'Calibri Light,sans-serif',
          fontWeight: 600,
          cssClass: 'apexcharts-yaxis-title'
        }
      } },
      xaxis: { categories: ['Employees', 'Workers', 'Communities', 'Value chain partners', 'Customers'] },
      colors: ['#B7D93D', '#B7D93D', '#B7D93D', '#B7D93D', '#B7D93D']
    };
    var industryStatus = data.industry_status;
    if(industryStatus == 'default') {
    if (data.answers[0].checkbox_name == 'Yes, there is a grievance mechanism in place for following stakeholders' || data.answers[0].checkbox_name == 'information_available') {
      const buttonClasses = ['pb5_button1', 'pb5_button2', 'pb5_button3', 'pb5_button4', 'pb5_button5'];
      const indices = [0, 1, 2, 3, 4];
      
      buttonClasses.forEach((buttonClass, idx) => {
        const answer = data.answers[indices[idx]].ans;
        const $button = $(`.${buttonClass}`);
    
        $button.addClass('grey-hexagon');  // Set default class
    
        if (answer) {
          $button.removeClass('grey-hexagon').addClass('green-hexagon');
        }else {
          $button.removeClass('grey-hexagon').addClass('red-hexagon');
        }
      });
    } else {
      $('.pb5_commonclass').addClass('grey-hexagon');
    }
    }
    if(industryStatus == 'default') {
      new ApexCharts(document.querySelector("#chartpb-05-1"), options).render();
    }else {
      new ApexCharts(document.querySelector("#chartpb-05-2"), options).render();
    }
    
  }

  function convertPercentToNumber(percentString) {
    if (typeof percentString === 'string') {
      return parseFloat(percentString.replace('%', '')) || 0;
    }
    return percentString || 0;
  }

  function calculateAverage(dataArray) {
     
  if (!dataArray || dataArray === 0) return 0;
  
  return dataArray / 4;
}

  function renderLineChart(container, calculateAverageCY, calculateAveragePY, averageTotal, calculateAverageLY, companyAverageCY, companyAverageTotal, labels, title) {
    const options = {
      series: [
        {
          name: 'Male',
          type: 'column',
          color: '#150E40',
          data: calculateAverageCY
        },
        {
          name: 'Female',
          type: 'column',
          color: '#B7D93D',
          data: calculateAveragePY
        },
        {
          name: 'Total',
          type: 'column',
          color: '#D40F66',
          data: averageTotal
        },
        {
          name: 'Male company data',
          type: 'line',
          color: '#00D4E1',
          data: calculateAverageLY
        },
        {
          name: 'Female company data',
          type: 'line',
          color: '#780096',
          data: companyAverageCY
        },
        {
          name: 'Total company data',
          type: 'line',
          color: '#FF0000',
          data: companyAverageTotal
        }
      ],
      chart: {
        height: 350,
        width: 300,
        type: 'line',
        stacked: false,
        toolbar: {
          show: false // This will hide the toolbar
        }
      },
      stroke: {
        width: [0, 0, 1, 1],
        curve: 'smooth'
      },
      plotOptions: {
        bar: {
          columnWidth: '55%',
          endingShape: 'rounded'
        }
      },
      dataLabels: {
        enabled: true,
        enabledOnSeries: [0, 1, 2, 3, 4, 5],
        style: {
          fontSize: '10px',
          colors: ['#000']
        },
        offsetY: -10,
        formatter: function (val) {
          //return val; // Adjust the number of decimal places as needed
        }
      },
      markers: {
        size: [6, 6, 6, 6]
      },
      title: {
        text: title,
        align: 'center',
        style: {
          color: undefined,
          fontSize: '12px',
          //fontFamily: 'Calibri Light,sans-serif',
          fontWeight: 600,
          cssClass: 'apexcharts-yaxis-title'
        }
      },
      
      xaxis: {
        categories: labels,
      },
      yaxis: [{
        title: {
          text: 'Turnover rate',
        },
        min: 0, // Set the minimum value of the y-axis
        max: 50, // Set the maximum value of the y-axis
        tickAmount: 10, // Define the number of ticks
      }],
      fill: {
        opacity: [1, 1, 0.85, 0.85]
      },
      legend: {
        show: true,
        fontSize: '10px', // Set the font size for the legend text
        fontFamily: 'Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif', // Set the font family for the legend text
        fontWeight: 400, // Set the font weight for the legend text
        labels: {
          colors: ['#333'], // Set the color for the legend text
          useSeriesColors: false // Use the colors specified here, not the series colors
        }
      }
    };
    
    new ApexCharts(document.querySelector(container), options).render();
  }

  function renderPieChart(container, series, labels, width, color, legendStatus) {
    const options = {
      series,
      chart: { width: width, type: 'pie' },
      labels,
      colors: color,
      legend: { // Add this section to hide the legend
        show: legendStatus,
        fontSize: '10px',
        color: 'black',
        fontFamily: '"Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif',
        offsetX: 0, // Adjust this value to move the legend horizontally
        offsetY: -15, // Adjust this value to move the legend vertically closer to the chart
    },
      responsive: [{
        breakpoint: 480,
        options: {
          chart: { width: 200 },
          legend: { show: false, position: 'top' },
        },
      }],
    };
    new ApexCharts(document.querySelector(container), options).render();
  }

  function renderVerticalBarChart(container, averageSeries, maximumSeries, minimumSeries, labels) {
    const options = {
          series: [{
          name: 'Average',
          data: averageSeries
        }, {
          name: 'Maximum',
          data: maximumSeries
        }, {
          name: 'Minimum',
          data: minimumSeries
        }],
          chart: {
          type: 'bar',
          height: 350,
          width: 430,
          stacked: true,
          toolbar: {
            show: false // This will hide the toolbar
          }
        },
        colors: ['#4F5939', '#150E40', '#B7D93D'],
        responsive: [{
          breakpoint: 480,
          options: {
            legend: {
              position: 'bottom',
              offsetX: -10,
              offsetY: 0
            }
          }
        }],
        xaxis: {
          categories: labels,
        },
        yaxis: [{
          title: {
            text: 'Frequency Rate',
          }
        }],
        fill: {
          opacity: 1
        },
        legend: {
          position: 'right',
          offsetX: 0,
          offsetY: 50
        },
    };
    new ApexCharts(document.querySelector(container), options).render();
  }

  function renderColumnChart(container, seriesData, labels, title, maxValue, tickAmount, width) {
    const options = {
      series: seriesData,
      chart: {
        height: 350,
        width: width,
        type: 'line',
        stacked: true,
        toolbar: {
          show: false // This will hide the toolbar
        }
      },
      colors: ['#150E40', '#B7D93D', '#00D4E1'],
      dataLabels: {
        enabled: true,
      },
      stroke: {
        width: [1, 1, 1]
      },
      title: {
        text: '',
        align: 'left',
        offsetX: 110
      },
      xaxis: {
        categories: labels,
        labels: {
          style: {
            fontSize: '9px'
          }
        }
      },
      yaxis: [{
        min: 0,
        max: maxValue,
        tickAmount: tickAmount,
        axisTicks: {
          show: true,
        },
        axisBorder: {
          show: true,
          color: '#000'
        },
        labels: {
          style: {
            colors: '#000'
          }
        },
        title: {
          text: title,
          style: {
            color: '#000'
          }
        },
        tooltip: {
          enabled: true
        }
      }, {
        min: 0,
        max: maxValue,
        tickAmount: tickAmount,
        opposite: true,
        axisTicks: {
          show: true,
        },
        axisBorder: {
          show: true,
          color: '#B7D93D'
        },
        labels: {
          style: {
            colors: '#B7D93D'
          }
        },
        title: {
          text: 'Maximum',
          style: {
            color: '#B7D93D'
          }
        }
      }, {
        min: 0,
        max: maxValue,
        tickAmount: tickAmount,
        opposite: true,
        axisTicks: {
          show: true,
        },
        axisBorder: {
          show: true,
          color: '#00D4E1'
        },
        labels: {
          style: {
            colors: '#00D4E1'
          }
        },
        title: {
          text: 'Minimum',
          style: {
            color: '#00D4E1'
          }
        }
      }],
      tooltip: {
        fixed: {
          enabled: true,
          position: 'topLeft', // topRight, topLeft, bottomRight, bottomLeft
          offsetY: 30,
          offsetX: 60
        }
      },
      legend: {
        horizontalAlign: 'left',
        offsetX: 40
      }
    };

    new ApexCharts(document.querySelector(container), options).render();
  }
  function renderCircleChart(container, series, labels, color){
    const options = {
      series: series,
      chart: {
      height: 300,
      type: 'radialBar',
    },
    plotOptions: {
      radialBar: {
        offsetY: 0,
        startAngle: 0,
        endAngle: 270,
        hollow: {
          margin: 5,
          size: '30%',
          background: 'transparent',
          image: undefined,
        },
        dataLabels: {
          name: {
            show: false,
          },
          value: {
            show: false,
          }
        },
        barLabels: {
          enabled: true,
          useSeriesColors: true,
          margin: 8,
          fontSize: '13px',
          formatter: function(seriesName, opts) {
            return opts.w.globals.series[opts.seriesIndex]
          },
        },
      }
    },
    colors: color,
    responsive: [{
      breakpoint: 480,
      options: {
        legend: {
            show: false
        }
      }
    }]
    };

    new ApexCharts(document.querySelector(container), options).render();
  }
  function renderRadialBarChart(container, series, labels, color) {
    const options = {
      series,
      chart: { height: 250, type: 'radialBar' },
      colors: [color],
      plotOptions: {
        radialBar: {
          hollow: { size: '70%' },
        },
      },
      labels,
    };
    new ApexCharts(document.querySelector(container), options).render();
  }

  function renderBarChart(container, series1, series2, labels, text, minValue) {
    const options = {
      series: [{
        name: 'R&D', // Label for the first data set
        data: series1 // Data for the first data set
      }, {
        name: 'Capex', // Label for the second data set
        data: series2 // Data for the second data set
      }],
      chart: {
        type: 'bar',
        height: 430,
        width:430,
        toolbar: {
          show: false // This will hide the toolbar
        }
      },
      plotOptions: {
        bar: {
          horizontal: true,
          dataLabels: {
            position: 'top',
          },
        }
      },
      dataLabels: {
        enabled: true,
        offsetX: -6,
        style: {
          fontSize: '12px',
          colors: ['#fff']
        },
        formatter: function (val, opts) {
          // Retrieve the original value for the current data point
          const originalValue = opts.w.config.series[opts.seriesIndex].data[opts.dataPointIndex] === minValue ? 0 : val;
          return originalValue;
        }
      },
      stroke: {
        show: true,
        width: 1,
        colors: ['#fff']
      },
      tooltip: {
        shared: true,
        intersect: false
      },
      xaxis: {
        categories: labels,
        max: 100,
      },
      yaxis: [{
        show: true,
        title: {
          text: '% of companies',
        },
        style: {
          color: undefined,
          fontSize: '12px',
          fontWeight: 300,
          cssClass: 'apexcharts-yaxis-title'
        }
      }],
      title: {
        text: text,
        align: 'center'
      },
      colors: ['#150E40', '#B7D93D']
    };
    new ApexCharts(document.querySelector(container), options).render();
  }

  function renderrConditionalBarChart(data, container, labels) {
    const options = {
      series: [{
        name: 'Average',
        data: [data.company_data[0].average, data.company_data[1].average, data.company_data[2].average],
        color: '#150E40', // Blue color for Average
      }, {
        name: 'Maximum',
        data: [data.company_data[0].maximum, data.company_data[1].maximum, data.company_data[2].maximum],
        color: '#B7D93D' // Green color for Maximum
      }, {
        name: 'Minimum',
        data: [data.company_data[0].minimum, data.company_data[1].minimum, data.company_data[2].minimum],
        color: '#00D4E1' // Yellow color for Minimum
      }, {
        name: 'Company Data',
        data: [data.answers[0].ans, data.answers[1].ans, data.answers[2].ans],
        type: 'line', // Line type for Company Data
        color: '#FF662B', // Red color for Company Data
        marker: {
          size: 6
        }
      }],
      chart: {
        type: 'bar',
        height: 430,
        width:450,
        toolbar: {
          show: false // This will hide the toolbar
        }
      },
      plotOptions: {
        bar: {
          horizontal: true,
          dataLabels: {
            position: 'top',
          },
          columnWidth: '70%'
        }
      },
      dataLabels: {
        enabled: true,
        offsetX: -6,
        style: {
          fontSize: '12px',
          colors: ['#fff']
        }
      },
      stroke: {
        show: true,
        width: [1, 1, 1, 2],
        colors: ['#fff']
      },
      tooltip: {
        shared: true,
        intersect: false
      },
      xaxis: {
        categories: labels,
        max:100
      },
      yaxis: [{
        title: {
          text: '% of turnover',
        }
      }],
      markers: {
        size: 6
      },
      legend: {
        fontSize: '11px', // Change this value to your desired font size
      }
    };
    new ApexCharts(document.querySelector(container), options).render();
    
  }
//------------------------chart code ends----------------------------------------------------
  
async function generatePDF(content) {
  try {
    var pdf = await html2pdf().from(content).set({
      margin: [5, 2, 5, 2],
      html2canvas: { dpi: 300, letterRendering: true },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
    }).toPdf().get('pdf');

    var pdfBlob = pdf.output('blob');
    return pdfBlob;
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw error;
  }
}

document.getElementById('savePdfBtn').addEventListener('click', async function () {
  document.getElementById("loader-wrapper").style.display = "block";
  var button = document.getElementById('savePdfBtn');
  var companyName = button.getAttribute('data-id');
  var today = new Date();
  var dateStr = today.getFullYear() + "-" + (today.getMonth() + 1).toString().padStart(2, '0') + "-" + today.getDate().toString().padStart(2, '0');

  var content1 = document.getElementById('content1');
  var content2 = document.getElementById('content2');
  var content3 = document.getElementById('content3');

  try {
    var pdfBlob1 = await generatePDF(content1);
    var pdfBlob2 = await generatePDF(content2);
    var pdfBlob3 = await generatePDF(content3);

    var mergedPdfBlob = await mergePDFs(pdfBlob1, pdfBlob2, pdfBlob3);
    var finalPdfBlob = await addPageNumbers(mergedPdfBlob);

    saveAndDownloadPDF(finalPdfBlob, companyName + dateStr + ".pdf");

    await uploadPDF(finalPdfBlob, companyName + dateStr + ".pdf");

  } catch (error) {
    console.error('Error occurred:', error);
  }

  document.getElementById("loader-wrapper").style.display = "none";
});

async function mergePDFs(pdfBlob1, pdfBlob2, pdfBlob3) {
  try {
    const pdf1 = await PDFDocument.load(await pdfBlob1.arrayBuffer());
    const pdf2 = await PDFDocument.load(await pdfBlob2.arrayBuffer());
    const pdf3 = await PDFDocument.load(await pdfBlob3.arrayBuffer());

    const mergedPdf = await PDFDocument.create();

    const copiedPages1 = await mergedPdf.copyPages(pdf1, pdf1.getPageIndices());
    copiedPages1.forEach((page) => mergedPdf.addPage(page));

    const copiedPages2 = await mergedPdf.copyPages(pdf2, pdf2.getPageIndices());
    copiedPages2.forEach((page) => mergedPdf.addPage(page));

    const copiedPages3 = await mergedPdf.copyPages(pdf3, pdf3.getPageIndices());
    copiedPages3.forEach((page) => mergedPdf.addPage(page));

    const mergedPdfBytes = await mergedPdf.save();
    const mergedPdfBlob = new Blob([mergedPdfBytes], { type: 'application/pdf' });

    return mergedPdfBlob;
  } catch (error) {
    console.error('Error merging PDFs:', error);
    throw error;
  }
}

async function addPageNumbers(pdfBlob) {
  try {
    const pdf = await PDFDocument.load(await pdfBlob.arrayBuffer());
    const totalPages = pdf.getPageCount();
    const pageHeight = pdf.getPage(0).getHeight();

    for (let i = 0; i < totalPages; i++) {
      const page = pdf.getPage(i);
      const pageText = `            ${i + 1}`;
      page.drawText(pageText, {
        x: (page.getWidth() / 2) - 50,
        y: 20,
        size: 12
      });
    }

    const pdfBytes = await pdf.save();
    const finalPdfBlob = new Blob([pdfBytes], { type: 'application/pdf' });

    return finalPdfBlob;
  } catch (error) {
    console.error('Error adding page numbers:', error);
    throw error;
  }
}

function saveAndDownloadPDF(pdfBlob, fileName) {
  var link = document.createElement('a');
  link.href = URL.createObjectURL(pdfBlob);
  link.download = fileName;
  link.click();
}

function uploadPDF(pdfBlob, fileName) {
  var formData = new FormData();
  formData.append('pdfreportfile', pdfBlob, fileName);
  var csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  return $.ajax({
    url: '/company_user/peer_benchmark/upload_pdf',
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken
    },
    data: formData,
    processData: false,
    contentType: false,
    success: function (response) {
      console.log('PDF uploaded successfully:', response);
    },
    error: function (error) {
      console.error('Error occurred:', error);
    }
  });
}
  };
});
