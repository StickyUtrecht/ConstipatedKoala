// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function(){
  $('footer.table-footer .pagination-container li a[data-offset]').bind( 'click', function(e) {
    var params = {};
    params['limit'] = $('footer.table-footer .page-num-info').attr('data-limit');
    params['offset'] = $(this).attr('data-offset');
        
    e.preventDefault();
    location.search = $.param(params);
  });
  
  $('footer.table-footer .pagination-container li.scroll a').bind( 'click', function(e) {
    
  });

  $('footer.table-footer .page-num-info select').bind( 'change', function() {
    var params = {}, limit = $(this).val();
    $('footer.table-footer .page-num-info').attr('data-limit', limit);
    
    params['limit'] = limit;
    params['offset'] = $('footer.table-footer .pagination-container li.active a').attr('data-offset');
    location.search = $.param(params);
  });
  
  $('div.cards ul.list-group button.activate').bind( 'click', function() {
    var button = $( this );
    var row = $( this ).closest('.list-group-item');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    
    //disable
    $( button ).attr('disabled', 'disabled');
    
    $.ajax({
      url: '/checkout/card',
      type: 'PATCH',
      data: {
        uuid: $( row ).attr('data-uuid'),
        authenticity_token: token
      }
    }).done(function(){          
      alert('kaart geactiveerd', 'success');
      $( row ).remove();
    }).fail(function(){                  
      alert('kaart is niet geactiveerd', 'error');
      $( button ).removeAttr('disabled');
    });
  });
});