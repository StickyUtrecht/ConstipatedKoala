// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
//= require bootstrap-file-input

$(document).on( 'ready page:load turbolinks:load', function(){

  $( '#settings input[id^=\'options\']' ).on( 'change', function( e ){
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));
    var obj = this;

    $.ajax({
      url: '/settings',
      type: 'POST',
      data: {
        authenticity_token: token,
        setting: obj.name,
        value: obj.value
      }
    }).done(function( data, status ){
      toastr.success($(obj).parents('.list-group-item').find('.col-md-6 b').html() + ' aangepast');

      if( !data )
        return;

      if( 'activities' in data )
        $(obj).val(data.activities);

      if( 'warning' in data && data.warning === true )
        toastr.warning('Niet alle activiteiten gevonden');
    }).fail(function(){
      toastr.error('Instelling is niet opgeslagen');
    });
  });

  // remove advert
  $( 'div#advertisements tr .btn-group button.destroy' ).bind( 'click', function() {
    var button = $( this );
    var row = $( this ).closest( 'tr' );
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    $.ajax({
      url: '/settings/advertisement',
      type: 'DELETE',
      data: {
        id: $( row ).attr( 'data-id' ),
        authenticity_token: token
      }
    }).done(function( data, status ){
      toastr.success('Advertentie verwijderd');
      $( row ).remove();
    }).fail(function(){
      toastr.error('Advertentie is niet verwijderd');
    });
  });

  $('li.disabled a').on('click', function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    return false;
  });
});
