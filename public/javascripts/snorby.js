// Snorby - A Web interface for Snort.
// 
// Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

var selected_events = [];
var flash_message = [];
var csrf = $('meta[name="csrf-token"]').attr('content');

function HCloader(element) {
  var $holder = $('div#' + element);
  $holder.fadeTo('slow', 0.2);
  
  var $el = $('<div class="cover-loader" />');
  
  $el.css({
    top: $holder.offset().top,
    left: $holder.offset().left,
    height: $holder.height(),
    width: $holder.width(),
    'line-height': $holder.height() + 'px'
  }).html('Loading...');
  
  $el.appendTo('body');

};

function clippyCopiedCallback(a) {
  var b = $('span#main_' + a);
	b.length != 0 && (b.attr("title", "copied!").trigger('tipsy.reload'), setTimeout(function() {
		b.attr("title", "copy to clipboard")
	},
	500))
};

function Queue() {
  if ( !(this instanceof arguments.callee) ) {
    return new arguments.callee(arguments);
  }
  var self = this;
	
	self.up = function () {
		var current_count = parseInt($('span.queue-count').html());
		$('span.queue-count').html(current_count + 1);
	};
	
	self.down = function() {
		var current_count = parseInt($('span.queue-count').html());
		$('span.queue-count').html(current_count - 1);
	};

}

function flash (data) {
	$('div#flash_message').remove();

	$.each(flash_message, function(index, data) {
		var message = Snorby.templates.flash(data);
		$('body').prepend(message);
		$('div#flash_message').fadeIn('slow').delay(2000).fadeOut("slow");
		flash_message = [];
	});
	
	return false;
}

function clear_selected_events () {
	selected_events = [];
	$('input#selected_events').val('');
	return false;
}

function set_classification (class_id) {
	var selected_events = $('input#selected_events').attr('value');
	var current_page = $('div#events').attr('data-action');
	var current_page_number = $('div#events').attr('data-page');
	
	if (selected_events.length > 0) {
		$('div.content').fadeTo(500, 0.4);
		Snorby.helpers.remove_click_events(true);
		
		$.post('/events/classify', {events: selected_events, classification: class_id, authenticity_token: csrf}, function() {
			
			if (current_page == "index") {
				clear_selected_events();
				$.getScript('/events?page=' + current_page_number);
			} else if (current_page == "queue") {
				clear_selected_events();
				$.getScript('/events/queue?page=' + current_page_number);
			} else if (current_page == "history") {
				clear_selected_events();
				$.getScript('/events/history?page=' + current_page_number);
			} else if (current_page == "results") {
				clear_selected_events();
				$.getScript($('input#current_url').val());
			} else {
				// clear_selected_events();
				// $.getScript('/events');
			};

			flash_message.push({type: 'success', message: "Event(s) Classified Successfully"});
			
		});
		
	} else {
		
		if ($('ul.table div.content li.event.currently-over.highlight').is(':visible')) {
			
			$('ul.table div.content li.event.currently-over.highlight .row div.select input#event-selector').click().trigger('change');
			set_classification(class_id);
			
		} else {
			
			flash_message.push({type: 'error', message: "Please Select Events To Perform This Action"});
			flash();
			$.scrollTo('#header', 500);
			
		};
		
	};
}

function update_note_count (event_id, data) {
	
	var event_row = $('li#'+event_id+' div.row div.timestamp');
	var notes_count = event_row.find('span.notes-count');
	
	var template = '<span class="add_tipsy round notes-count" title="{{notes_count_in_words}}"><img alt="Notes" height="16" src="/images/icons/notes.png" width="16"></span>'
	var event_html = Snorby.templates.render(template, data);
  	
	if (data.notes_count == 0) {
		
		notes_count.remove();
		
	} else {
		
		if (notes_count.length > 0) {
			notes_count.replaceWith(event_html).trigger('tipsy.reload');
		} else {
			event_row.prepend(event_html).trigger('tipsy.reload');
		};
		
	};
	
}

var Snorby = {
	
	setup: function(){
		
		$(window).resize(function() {
			$.fancybox.center;
		});
		
		$('div#flash_message, div#flash_message > *').live('click', function() {
			$('div#flash_message').stop().fadeOut('fast');
		});
		
		$("#growl").notify({
		    speed: 500,
		    expires: 5000
		});
		
		$('.edit-sensor-name').editable("/sensors/update_name", {
			height: '20px',width: '180px',name: "name",
			indicator: '<img src="/images/icons/pager.gif">',
			data: function(value) {
				var retval = value.replace(/<br[\s\/]?>/gi, '\n');
				return retval;
			},
			submitdata : function() {
				return { id: $(this).attr('data-sensor-id'), authenticity_token: csrf };
			}
		});

	},
	
	pages: {
		
		classifications: function(){
			$('a.classification').live('click', function() {
				var class_id = $(this).attr('data-classification-id');
				set_classification(class_id);
				return false;
			});
		},
		
		dashboard: function(){
			
			$('#box-holder div.box').live('click', function(e) {
				e.preventDefault();
				window.location = $(this).attr('data-url');
				return false;
			});
			
			$('a.show_events_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#events-graph').show();
				return false;
			});

      $('a.show_map_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#geoip-graph').show();
				return false;
			});
			
			$('a.show_severities_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#severity-graph').show();
				return false;
			});
			
			$('a.show_protocol_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#protocol-graph').show();
				return false;
			});
			
			$('a.show_signature_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#signature-graph').show();
				return false;
			});
			
			$('a.show_classification_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#classification-graph').show();
				return false;
			});
			
			$('a.show_source_ips_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#source-ips-graph').show();
				return false;
			});
			
			$('a.show_destination_ips_graph').live('click', function(e) {
				e.preventDefault();
				$('#box-menu li').removeClass('active');
				$(this).parent('li').addClass('active');
				$('div.dashboard-graph').hide();
				$('div#destination-ips-graph').show();
				return false;
			});
			
		},
		
		events: function(){
			
			$('select.email-user-select').live('change', function(e) {
				var email = $('select.email-user-select').val();
				
				if (email != '') {
					if ($('input#email_to').val() == '') {
						$('input#email_to').val(email);
					} else {
						$('input#email_to').val($('input#email_to').val() + ', ' + email);
					};
				};
			});
			
			$('button.email-event-information').live('click', function(e) {
		    e.preventDefault();
				if ($('input#email_to').val() == '') {
					flash_message.push({type: 'error', message: "The email recipients cannot be blank."});flash();
					$.scrollTo('#header', 500);
				} else {
					if ($('input#email_subject').val() == '') {
						flash_message.push({type: 'error', message: "The email subject cannot be blank."});flash();
						$.scrollTo('#header', 500);
					} else {
						$('a#fancybox-close').click();
						$.post('/events/email', $('form.email-event-information').serialize(), null, "script");
					};
				};
				return false;
			});
			
			$('button.request_packet_capture').live('click', function(e) {
		    e.preventDefault();
				if ($(this).attr('data-deepsee')) { $('form.request_packet_capture input#method').val('deepsee') };
				$.post('/events/request_packet_capture', $('form.request_packet_capture').serialize(), null, "script");
				return false;
			});
			
			$('dl#event-sub-menu a').live('click', function(e) {
				$('dl#event-sub-menu').hide();
			});
			
			$('a.has-event-menu').live('click', function(e) {
				e.preventDefault();
				var menu = $(this).parent().find('dl.event-sub-menu');
				if (menu.is(':visible')) { menu.fadeOut('fast') } else { $('dl.event-sub-menu').hide(); menu.fadeIn('fast') };
				return false;
			});
		
      $('dl.event-sub-menu dd a').live('click', function(event) {
        $(this).parents('dl').fadeOut('fast');
      });

			$('button.mass-action').live('click', function(e) {
				e.preventDefault();
				var nform = $('form#mass-action-form');
				$('a#fancybox-close').click();
				$.post('/events/mass_action', nform.serialize(), null, "script");
				return false;
			});
			
			$('button.create-notification').live('click', function(e) {
				e.preventDefault();
				var nform = $('form#new_notification');
				$.post('/notifications', nform.serialize(), null, "script");
				$('a#fancybox-close').click();
				return false;
			});
			
			$('button.cancel-snorbybox').live('click', function(e) {
				e.preventDefault();
				$('a#fancybox-close').click();
				return false;
			});
			
			$('ul.payload-tabs li a').live('click', function(e) {
				e.preventDefault();
				
				var div_class = $(this).attr('data-div');
				
				$(this).parents('ul').find('li').removeClass('current');
				$(this).parent('li').addClass('current');
				$('div.payload-holder').hide();
				
				$('div.'+div_class+' pre').css('opacity', 0);
				
				$('div.'+div_class).show();
				
				$('div.'+div_class+' pre').stop().animate({"opacity": 1}, 1000);
				
				return false;
			});
			
			
			$('a.export').live('click', function(e) {
				e.preventDefault();
				var selected_events = $('input#selected_events').attr('value');
				
				if (selected_events) {
					
					$.post(this.href, { events: selected_events, authenticity_token: csrf});
					
				} else {
					flash_message.push({type: 'error', message: "Please Select Events To Perform This Action"});
					flash();
				};
				
				return false;
			});
		
			$('a.edit-event-note').live('click', function(e) {
				e.preventDefault();
				var note = $(this).parents('div.event-note');
				var note_id = $(this).attr('data-note-id');
				$.getScript('/notes/' + note_id + '/edit');
				return false;
			});
			
			$('a.destroy-event-note').live('click', function(e) {
				e.preventDefault();
				var note = $(this).parents('div.event-note');
				var note_id = $(this).attr('data-note-id');
				
				if ( confirm("Are you sure you want to delete this note?") ) {
					$('div.notes').fadeTo(500, 0.4);
					$.post('/notes/destroy', { id: note_id, authenticity_token: csrf, '_method': 'delete' }, null, 'script');
				};
				
				return false;
			});
			
			$('button.add_new_note-working').live('click', function(e) {
				e.preventDefault();
				return false;
			});
			
			$('button.cancel-note').live('click', function(e) {
				e.preventDefault();
				$(this).parents('div#new_note_box').remove();
				return false;
			});
			
			$('button.add_new_note').live('click', function(e) {
				e.preventDefault();
				var event_sid = $(this).parent('div#form-actions').parent('div#new_note').attr('data-event-sid');
				var event_cid = $(this).parent('div#form-actions').parent('div#new_note').attr('data-event-cid');
				
				if ($('div#new_note_box').length > 0) {
					
				} else {
					$(this).removeClass('add_new_note').addClass('add_new_note-working');
					
					var current_width = $(this).width();
					$(this).addClass('loading').css('width', current_width);
					
					$.get('/notes/new', { sid: event_sid, cid: event_cid, authenticity_token: csrf}, null, 'script');
				};
				
				return false;
			});
			
			$('button.submit_new_note').live('click', function(e) {
				e.preventDefault();
				var event_sid = $(this).parent('div#form-actions').parent('div#new_note').attr('data-event-sid');
				var event_cid = $(this).parent('div#form-actions').parent('div#new_note').attr('data-event-cid');
				var note_body = $(this).parent('div#form-actions').parent('div#new_note').find('textarea#body').val();
				
				if (note_body.length > 0) {
					
					var current_width = $(this).width();
					$(this).addClass('loading').css('width', current_width);
					
					$.post('/notes/create', { sid: event_sid, cid: event_cid, body: note_body, authenticity_token: csrf}, null, 'script');
					
				} else {
					flash_message.push({type: "error", message: "The note body cannot be blank!"}); 
					flash();
					$.scrollTo('#header', 500);
				};
				
				return false;
			});
			
			$('a.query-data').live('click', function() {
				$('pre.query-data-content').hide();
				$('pre#' + $(this).attr('data-content-name')).show();
				return false;
			});
		
      $('a.snorbybox-content').live('click', function(event) {
        event.preventDefault();
        $('dl.drop-down-menu').fadeOut('slow');
				var content = $(this).attr('data-content');

        $.fancybox({
					padding: 0,
          content: content,
					centerOnScroll: true,
	        zoomSpeedIn: 300, 
	        zoomSpeedOut: 300,
					overlayShow: true,
					overlayOpacity: 0.5,
					overlayColor: '#000',
					onStart: function() {
            Snorby.eventCloseHotkeys(false);
						$('dl#event-sub-menu').hide();
					},
					onClosed: function() {
            Snorby.eventCloseHotkeys(true);
					}
				});
      });

			$('a.snorbybox').live('click', function() {
				$('dl.drop-down-menu').fadeOut('slow');
				$.fancybox({
					padding: 0,
					centerOnScroll: true,
	        zoomSpeedIn: 300, 
	        zoomSpeedOut: 300,
					overlayShow: true,
					overlayOpacity: 0.5,
					overlayColor: '#000',
					href: this.href,
					onStart: function() {
            Snorby.eventCloseHotkeys(false);
						$('dl#event-sub-menu').hide();
					},
					onClosed: function() {
					  Snorby.eventCloseHotkeys(true);
					}
				});
				return false;
			});
			
			$('div.create-favorite.enabled').live('click', function() {
				var sid = $(this).parents('li.event').attr('data-event-sid');
				var cid = $(this).parents('li.event').attr('data-event-cid');
				
				$(this).removeClass('create-favorite').addClass('destroy-favorite');
				$.post('/events/favorite', { sid: sid, cid: cid, authenticity_token: csrf});
				
				var count = new Queue();
				count.up();
				
				return false;
			});
			
			$('div.destroy-favorite.enabled').live('click', function() {
				var sid = $(this).parents('li.event').attr('data-event-sid');
				var cid = $(this).parents('li.event').attr('data-event-cid');
				var action = $('div#events').attr('data-action');
				
				$(this).removeClass('destroy-favorite').addClass('create-favorite');
				$.post('/events/favorite', { sid: sid, cid: cid, authenticity_token: csrf});
				
				var count = new Queue();
				count.down();
				
				if (action == 'queue') { 
					$('div.content').fadeTo(500, 0.4);
					Snorby.helpers.remove_click_events(true);
					$('div.destroy-favorite').removeClass('enabled').css('cursor', 'default');
					$.get('/events/queue', null, null, "script");
				};
					
				return false;
			});

			$('input.event-select-all').live('change', function() {
				if ($(this).attr('checked')) {
					$('ul.table div.content li.event input.event-selector').attr('checked', true);
				} else {
					$('ul.table div.content li.event input.event-selector').attr('checked', false);
				};
				return true;
			});
			
			$('ul.table div.content li.event div.click').live('click', function() {
        var self = $(this);

				$('dl#event-sub-menu').hide();
				
				var sid = $(this).parents('li').attr('data-event-sid');
				var cid = $(this).parents('li').attr('data-event-cid');
				var parent_row = $('li#event_'+sid+''+cid);
				var check_box = $('li#event_'+sid+''+cid+' input#event-selector');
				
				var current_row = $('li#event_'+sid+''+cid+' div.event-data');
				
				Snorby.helpers.remove_click_events(true);
				$('li.event').removeClass('highlight');
				
				if (!current_row.is(':visible')) {
					parent_row.addClass('highlight');
				} else {
					parent_row.removeClass('highlight');
				};
				
				if (current_row.attr('data') == 'true') {
					Snorby.helpers.remove_click_events(false);

					if (current_row.is(':visible')) {
            
						current_row.slideUp('fast', function () {
							$('li.event div.event-data').slideUp('fast');
              Snorby.eventCloseHotkeys(true);
						});
            
					} else {
						$('li.event div.event-data').slideUp('fast');
						current_row.slideDown('fast', function() {

              $(document).bind('keydown', 'esc', function() {
                $('li.event').removeClass('highlight');
                parent_row.removeClass('highlight');

                current_row.slideUp('fast', function () {
                  $('li.event div.event-data').slideUp('fast');
                });
              
                Snorby.eventCloseHotkeys(true);
                $(this).unbind('keydown', 'esc');
              });

              Snorby.eventCloseHotkeys(false);
						});
					};

				} else {
					
					check_box.hide();
					$('li.event div.event-data').slideUp('fast');
					parent_row.find('div.select').append("<img alt='laoding' src='/images/icons/loading.gif' class='select-loading'>");

					$.get('/events/show/'+sid+'/'+cid, function () {

            $(document).bind('keydown', 'esc', function() {
              $('li.event').removeClass('highlight');
              parent_row.removeClass('highlight');

						  current_row.slideUp('fast', function () {
							  $('li.event div.event-data').slideUp('fast');
						  });
            
              $(this).unbind('keydown', 'esc');
              Snorby.eventCloseHotkeys(true);
            });

						Snorby.helpers.remove_click_events(false);

						$('.select-loading').remove();
						check_box.show();
						current_row.attr('data', true);

            Snorby.eventCloseHotkeys(false);
					}, 'script');
					
				};
				
				return false;
			});

			$('div.new_events').live('click', function() {
				$(this).remove();
				if (parseInt($('strong.new_event_count').html()) > 100) {
					window.location = '/events'
				} else {
					$('#events ul.table div.content li').fadeIn('slow');
				};
				return false;
			});

		},
		
	},
	
  eventCloseHotkeys: function(bind) {
    if (bind) {
      $(document).bind('keydown', 'shift+right', Snorby.hotKeyCallback.shiftPlusRight);
      $(document).bind('keydown', 'right', Snorby.hotKeyCallback.right);			
      $(document).bind('keydown', 'shift+left', Snorby.hotKeyCallback.shiftPlusLeft);
      $(document).bind('keydown', 'left', Snorby.hotKeyCallback.left);      
    } else {
      $(document).unbind('keydown', Snorby.hotKeyCallback.shiftPlusRight);
      $(document).unbind('keydown', Snorby.hotKeyCallback.right);			
      $(document).unbind('keydown', Snorby.hotKeyCallback.shiftPlusLeft);
      $(document).unbind('keydown', Snorby.hotKeyCallback.left);
    }
  },

	admin: function(){
		
		$('#users input#enabled').live('click', function(e) {
			var user_id = $(this).parent('td').attr('data-user');
			if ($(this).attr('checked')) {
				$.post('/users/toggle_settings', { user_id: user_id, user: { enabled: true }, authenticity_token: csrf});
			} else {
				$.post('/users/toggle_settings', { user_id: user_id, user: { enabled: false }, authenticity_token: csrf});
			};
		});
		
		$('#users input#admin').live('click', function(e) {
			var user_id = $(this).parent('td').attr('data-user');
			if ($(this).attr('checked')) {
				$.post('/users/toggle_settings', { user_id: user_id, user: { admin: true }, authenticity_token: csrf});
			} else {
				$.post('/users/toggle_settings', { user_id: user_id, user: { admin: false }, authenticity_token: csrf});
			};
		});
		
		$('#severity-color-bg').ColorPicker({
			color: $('#severity-color-bg').attr('value'),
			onShow: function (colpkr) {
				$(colpkr).fadeIn(500);
				return false;
			},
			onHide: function (colpkr) {
				$(colpkr).fadeOut(500);
				return false;
			},
			onSubmit: function(hsb, hex, rgb, el) {
					$(el).ColorPickerHide();
			},
			onChange: function (hsb, hex, rgb) {
				$('#severity-color-bg').val('#'+hex);
				$('span.severity').css('backgroundColor', '#' + hex);
			}
		});
		
		$('#severity-color-text').ColorPicker({
			color: $('#severity-color-text').attr('value'),
			onShow: function (colpkr) {
				$(colpkr).fadeIn(500);
				return false;
			},
			onHide: function (colpkr) {
				$(colpkr).fadeOut(500);				
				return false;
			},
			onSubmit: function(hsb, hex, rgb, el) {
					$(el).ColorPickerHide();
			},
			onChange: function (hsb, hex, rgb) {
				$('#severity-color-text').val('#'+hex);
				$('span.severity').css('color', '#' + hex);
			}
		});
	},
	
	templates: {
	
    render: function(source, data) {
      var self = this;

      var template = Handlebars.compile(source);
      return template(data);
    },

		flash: function(data){
      var self = this;

			var template = " \
			<div class='{{type}}' id='flash_message' style='display:none;'> \
				<div class='message {{type}}'>{{message}}</div> \
			</div>";
			return Snorby.templates.render(template, data);
		},
		
		event_table: function(data){
      var self = this;
      
      var klass = '';
      if (data.events[0].geoip) { klass = ' geoip' };

			var template = " \
			{{#events}} \
			<li id='event_{{sid}}{{cid}}' class='event' style='display:none;' data-event-id='{{sid}}-{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<div class='row"+klass+"'> \
					<div class='select small'><input class='event-selector' id='event-selector' name='event-selector' type='checkbox'></div> \
					<div class='important small'><div class='create-favorite enabled'></div></div> \
					<div class='severity small'><span class='severity sev{{severity}}'>{{severity}}</span></div> \
					<div class='click sensor'>{{hostname}}</div> \
          <div class='click src_ip address'> \
            {{{geoip this.src_geoip}}} {{ip_src}} \
          </div> \
					<div class='click dst_ip address'> \
            {{{geoip this.dst_geoip}}} {{ip_dst}} \
          </div> \
					<div class='click signature'>{{message}}</div> \
					<div class='click timestamp'> \
            <b class='add_tipsy' title='Event ID: {{sid}}.{{cid}} &nbsp; {{datetime}}'>{{timestamp}}</b> \
          </div> \
				</div> \
				<div style='display:none;' class='event-data' data='false'></div> \
			</li> \
			{{/events}}"
			
			return Snorby.templates.render(template, data);
		},
	},
	
	notification: function(message){
		$('#growl').notify("create", message,{
		    expires: 3000,
		    speed: 500
		});
	},
	
	helpers: {
		
		tipsy: function(){
			
			$('.add_tipsy').tipsy({
				fade: true,
				html: false,
				gravity: 's',
				live: true
			});
			
			$('.add_tipsy_html').tipsy({
				fade: true,
				html: true,
				gravity: 's',
				live: true
			});

		},
		
		input_style: function(){

			$('div#form-actions button.cancel').live('click', function() {
				window.location = '/';
				return false;
			});
			
			$('input[name=blank]').focus();

		},
		
		dropdown: function(){
			
			$(document).click(function() {
				$('dl.drop-down-menu:visible').hide();
			});
			
			$('dl.drop-down-menu dd a').live('click', function() {
				$('dl.drop-down-menu').fadeOut('slow');
				return true;
			});

			$('dl.drop-down-menu').hover(function() {
		    var timeout = $(this).data("timeout");
		    if(timeout) clearTimeout(timeout);
		  }, function() {
		      $(this).data("timeout", setTimeout($.proxy(function() {
		          $(this).fadeOut('fast');
		      }, this), 500));
		  });
			
			$('a.has_dropdown').live('click', function() {
				
				var id = $(this).attr('id');
				var dropdown = $(this).parents('li').find('dl#'+id);
				
				$('dl.drop-down-menu').each(function(index) {
				  
					if (id === $(this).attr('id')) {
						
						if ($(this).is(':visible')) {
							dropdown.fadeOut('fast');
						} else {
							dropdown.slideDown({
								duration: 'fast', 
								easing: 'easeOutSine'
							});
						};
						
					} else {
						$(this).fadeOut('fast') 
					};

				});
				return false;
			});
		},
		
		persistence_selections: function() {
			
			$('input#event-selector').live('change', function() {
				
				var event_id = $(this).parents('li').attr('data-event-id');
				
				if ($(this).attr('checked')) {
					
					selected_events.push(event_id);
					$('input#selected_events[type="hidden"]').val(selected_events);
					
				} else {
					
					var removeItem = event_id;
					selected_events = jQuery.grep(selected_events, function(value) {
						return value != removeItem;
					});
					
					$('input#selected_events[type="hidden"]').val(selected_events);
				};
				
			});
			
			$('input#event-select-all').live('change', function() {
				
				if ($(this).attr('checked')) {
					
					$('ul.table div.content li input[type="checkbox"]').each(function (index, value) {
						var event_id = $(this).parents('li').attr('data-event-id');
						$(this).attr('checked', 'checked');
						selected_events.push(event_id);
					});
					
				} else {
					
					$('ul.table div.content li input[type="checkbox"]').each(function (index, value) {
						var removeItem = $(this).parents('li').attr('data-event-id');
						$(this).attr('checked', '');
 						selected_events = jQuery.grep(selected_events, function(value) {
							return value != removeItem;
						});
					});
				};
			
				$('input#selected_events[type="hidden"]').val(selected_events);
				
			});
			
		},
		
		recheck_selected_events: function(){
			$('input#selected_events').val(selected_events);
			$.each(selected_events, function(index, value) {
				$('input.check_box_' + value).attr('checked', 'checked');
			});
		},
		
		pagenation: function() {
			
			$('ul.pager li').live('click', function() {
				var self = this;

				if (history && history.pushState) {
					$(window).bind("popstate", function() {
						$.getScript(location.href);
			    });
				};
				
				if (!$(self).hasClass('more')) {
					
					var current_width = $(self).width();
					if (current_width < 16) { var current_width = 16 };
					
					$(self).addClass('loading').css('width', current_width);
					
					if ($(self).parents('div').hasClass('notes-pager')) {
						$('div.notes').fadeTo(500, 0.4);
					} else {
						$('div.content, tbody.content').fadeTo(500, 0.4);
					};
					
					Snorby.helpers.remove_click_events(true);
					
					if (history && history.pushState) {
						
            $.getScript($(self).find('a').attr('href'), function() {
              history.pushState(null, document.title, $(self).find('a').attr('href'));
              $('div.content').fadeTo(500, 1);
              Snorby.helpers.remove_click_events(false);
              Snorby.helpers.recheck_selected_events();
              $.scrollTo('#header', 500);
            });

					} else {
						$.getScript($(self).find('a').attr('href'), function() {
              $('div.content').fadeTo(500, 1);
              Snorby.helpers.remove_click_events(false);
              Snorby.helpers.recheck_selected_events();
              $.scrollTo('#header', 500);
            });
					};
					
				};
				
				return false;
			});
			
		},
		
	remove_click_events: function(hide){
			if (hide) {
				$('ul.table div.content div').removeClass('click');
			} else {
				$('li.event div.sensor, li.event div.src_ip, li.event div.dst_ip, li.event div.signature, li.event div.timestamp').addClass('click');
			};			
		},
	},
	
	callbacks: function(){

		$('body').ajaxError(function (event, xhr, ajaxOptions, thrownError) {
			
			$('div.content').fadeTo(500, 1);
			$('ul.table div.content li input[type="checkbox"]').attr('checked', '');
			Snorby.helpers.remove_click_events(false);
			
			if (xhr['status'] === 404) {
				flash_message.push({type: 'error', message: "The requested page could not be found."});
				flash();
			} else {
				flash_message.push({type: 'error', message: "The request failed to complete successfully."});
				flash();
			};
			
		});
		
	},

  hotKeyCallback: {
      
    left: function() {
      $('div.pager.main ul.pager li.previous a').click();
    },

    right: function() {
      $('div.pager.main ul.pager li.next a').click();
    },

    shiftPlusRight: function() {
      $('div.pager.main ul.pager li.last a').click();
    },

    shiftPlusLeft: function() {
      $('div.pager.main ul.pager li.first a').click();
    }

  },

	hotkeys: function(){
    var self = this;

		$(document).bind('keydown', 'ctrl+shift+h', function() {
			$.fancybox({
				padding: 0,
				centerOnScroll: true,
        zoomSpeedIn: 300, 
        zoomSpeedOut: 300,
				overlayShow: true,
				overlayOpacity: 0.5,
				overlayColor: '#000',
				href: '/events/hotkey'
			});
			return false;
		});
		
		$(document).bind('keydown', 'ctrl+3', function() {
			window.location = '/jobs';
			return false;
		});
	
		$(document).bind('keydown', 'ctrl+2', function() {
			window.location = '/events';
			return false;
		});
		
		$(document).bind('keydown', 'ctrl+1', function() {
			window.location = '/events/queue';
			return false;
		});
	
		$(document).bind('keydown', 'ctrl+shift+s', function() {
			window.location = '/search';
			return false;
		});
	
		if ($('div.pager').is(':visible')) {
			
			$(document).bind('keydown', 'shift+down', function() {
        var item = $('ul.table div.content li.event.currently-over');
        
				if (item.is(':visible')) {
          if (item.next().length != 0) {
            item.removeClass('currently-over');
            item.next().addClass('currently-over');
          } else {
            $('ul.table div.content li.event:first').addClass('currently-over');
          };
				} else {
					$('ul.table div.content li.event:first').addClass('currently-over');
				};

			});

			$(document).bind('keydown', 'shift+up', function() {
        var item = $('ul.table div.content li.event.currently-over');
				if (item.is(':visible')) {
          if (item.prev().length != 0) {
            item.removeClass('currently-over');
            item.prev().addClass('currently-over');
          } else {
            $('ul.table div.content li.event:last').addClass('currently-over');
          };
				} else {
					$('ul.table div.content li.event:last').addClass('currently-over');
				};
			});
			
			$(document).bind('keydown', 'shift+return', function() {
				$('ul.table div.content li.event.currently-over div.row div.click').click();
			});
			
			$(document).bind('keydown', 'ctrl+shift+1', function() {
        
        $('span.sev1').parents('div.row').find('input#event-selector').each(function() {
          var $checkbox = $(this);
          $checkbox.attr('checked', !$checkbox.attr('checked'));
          $checkbox.trigger('change');
        });
			});
			
			$(document).bind('keydown', 'ctrl+shift+2', function() {
        $('span.sev2').parents('div.row').find('input#event-selector').each(function() {
          var $checkbox = $(this);
          $checkbox.attr('checked', !$checkbox.attr('checked'));
          $checkbox.trigger('change');
        });
			});
			
			$(document).bind('keydown', 'ctrl+shift+3', function() {
        $('span.sev3').parents('div.row').find('input#event-selector').each(function() {
          var $checkbox = $(this);
          $checkbox.attr('checked', !$checkbox.attr('checked'));
          $checkbox.trigger('change');
        });
			});
			
			$(document).bind('keydown', 'ctrl+shift+u', function() {
				set_classification(0);
			});

      $(document).bind('keydown', 'alt+right', function() {
        $('div.pager.notes-pager ul.pager li.next a').click();
      });

      $(document).bind('keydown', 'alt+left', function() {
        $('div.pager.notes-pager ul.pager li.previous a').click();
      });
			
			$(document).bind('keydown', 'ctrl+shift+a', function() {
				$('input.event-select-all').click().trigger('change');
			});
			
      Snorby.eventCloseHotkeys(true);

		};
		
	},
	
	validations: function(){
		
		jQuery.validator.addMethod("hex-color", function(value, element, param) {
			return this.optional(element) || /^#?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$/i.test(value); 
		}, jQuery.validator.messages.url);
		
		$('.validate').validate();
		
	},
	
	settings: function(){
		
		if ($('div#general-settings').length > 0) {
			
			if ($('input#_settings_packet_capture:checked').length > 0) {
				$('div.pc-settings').show();
				$('p.pc-settings input[type="text"], p.pc-settings select').addClass('required');
			} else {
				$('div.pc-settings').hide();
				$('p.pc-settings input[type="text"], p.pc-settings select').removeClass('required');
			};

			if ($('input#_settings_packet_capture_auto_auth:checked').length == 0) {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', 'disabled');
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').removeClass('required');
			} else {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', '');
			};
			
			var packet_capture_plugin = $('select#_settings_packet_capture_type').attr('packet_capture_plugin');
			$('select#_settings_packet_capture_type option[value="'+packet_capture_plugin+'"]').attr('selected', 'selected');
			
      if ($('input#_settings_autodrop:checked').length > 0) {
        $('select#_settings_autodrop_count').attr('disabled', '');
      } else {
        $('select#_settings_autodrop_count').attr('disabled', 'disabled');
      };

      var autodrop_count = $('select#_settings_autodrop_count').attr('autodrop_count');
			$('select#_settings_autodrop_count option[value="'+autodrop_count+'"]').attr('selected', 'selected');
		};

		$('input#_settings_packet_capture').live('click', function() {
			if ($('input#_settings_packet_capture:checked').length > 0) {
				$('div.pc-settings').show();
				$('p.pc-settings input[type="text"], p.pc-settings select').addClass('required');
			} else {
				$('div.pc-settings').hide();
				$('p.pc-settings input[type="text"], p.pc-settings select').removeClass('required');
			};
		});

    $('input#_settings_autodrop').live('click', function() {
      console.log('w0ots!')
      if ($(this).is(':checked')) {
        $('select#_settings_autodrop_count').attr('disabled', '');
      } else {
        $('select#_settings_autodrop_count').attr('disabled', 'disabled');
      };
    });

		$('input#_settings_packet_capture_auto_auth').live('click', function() {
			if ($('input#_settings_packet_capture_auto_auth:checked').length > 0) {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').addClass('required');
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', '');
			} else {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').removeClass('required');
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', 'disabled');
			};
		});
		
	},
	
	jobs: function(){
		
		$('a.view_job_handler, a.view_job_last_error').live('click', function() {
			$.fancybox({
				padding: 0,
				centerOnScroll: true,
        zoomSpeedIn: 300, 
        zoomSpeedOut: 300,
				overlayShow: true,
				overlayOpacity: 0.5,
				overlayColor: '#000',
				href: this.href
			});
			return false;
		});
		
	}
	
}

jQuery(document).ready(function($) {

  Handlebars.registerHelper('geoip', function(ip) {
    if (ip) {
      var name = ip.country_name;
      var code = ip.country_code2;
      if (name === "--") { name = 'N/A' };

      return '<span class="click ' +
      'country_flag add_tipsy_html" title="&lt;img class=&quot;flag&quot; ' +
      'src=&quot;/images/flags/'+code.toLowerCase()+'.png&quot;&gt; ' + name + '">' + code + '</span>'; 
    } else {
      return null;
    };
  });

  $('#login form#user_new').submit(function(event) {
    event.preventDefault();
    var self = $('#login');
    var that = this;
    
    if ($('input#user_password', that).attr('value').length > 1) {
      if ($('input#user_email', that).attr('value').length > 5) {

        $.post(that.action, $(that).serialize(), function(data) {
            if (data.success) {

              flash_message.push({
                type: 'success', 
                message: "Loading - Authentication Successful!"
              });
              flash();
              $.get(data.redirect, function(data) {
                self.fadeOut('slow', function() {
                  document.open();
                  document.write(data);
                  document.close();
                  history.pushState(null, 'Snorby - Dashboard', '/');
                });
              });
            } else {
              flash_message.push({
                type: 'error', 
                message: "Fail - Authentication Failure!"
              });
              flash();
            };
        });

      };
    };
  });

  $('#login button.forgot-my-password').live('click', function(event) {
    event.preventDefault();
    $.get('/users/password/new', function(data) {
      var content = $(data).find('#content').html();
      $('#content').html(content);
      history.pushState(null, 'Snorby - Password Reset', '/users/password/new');
    });
  });

  $('#fancybox-wrap').draggable({
    handle: 'div#box-title',
    cursor: 'move'
  });

  $('li.administration a').live('click', function(event) {
    var self = this;
    event.preventDefault();
    $('dl#admin-menu').toggle();
  });

  $('dl#admin-menu a').live('click', function(event) {
    $(this).parents('dl').fadeOut('fast');
  });

  $('#wrapper').live('click', function() {
    if ($('dl#admin-menu').is(':visible')) {
      $('dl#admin-menu').fadeOut('fast');
    };
  });

  $('td.search-by-click').live('click', function(event) {
    event.preventDefault();
    var url = $(this).attr('data-url');
    window.location = url;
  });

	Snorby.setup();
	Snorby.admin();
	Snorby.callbacks();
	Snorby.hotkeys();
	Snorby.jobs();
	Snorby.settings();
	Snorby.validations();
	
	Snorby.helpers.tipsy();
	Snorby.helpers.dropdown();
	Snorby.helpers.input_style();
	Snorby.helpers.persistence_selections();
	Snorby.helpers.pagenation();
	
	Snorby.pages.classifications();
	Snorby.pages.dashboard();
	Snorby.pages.events();

  $('.add_chosen').chosen();

  $('ul.table div.content li.event').live('hover', function() {
    $('ul.table div.content li.event').removeClass('currently-over');
    $(this).toggleClass('currently-over');
  }, function() {
    $(this).toggleClass('currently-over');
  });

});
