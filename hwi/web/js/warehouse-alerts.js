(function ($, io) {
  var socket = io.connect('http://172.21.168.118:17003');
  socket.emit('warehouse_alerts');
  socket.on('alert', function(data){ 
      if (data.message != "") {
          alertMsg = "<h4>Warehouse Alert!</h4>Posted: " + data.date;
          alertMsg += "<br/>Estimated Time To Resolve: " + moment.utc(data.ttl*1000).format('H [Hours] m [Minutes]');
          alertMsg += "<br/><br/><b>" + data.message +"</b>";
          $('#dw-alert-msg')
              .hide()
              .removeClass()
              .addClass('alert alert-' + data.status)
              .html(alertMsg)
              .slideDown(200);
      } else {
          $('#dw-alert-msg').slideUp(200);
      }
  });
  socket.on('expire', function(data){
      $('#dw-alert-msg')
          .removeClass()
          .addClass("alert alert-success")
          .html("<b style='font-size:12pt'>All Clear!</b>");
  });
}(jQuery, io));