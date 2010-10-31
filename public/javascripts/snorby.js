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

var Snorby = {
	
	setup: function(){

		$("#growl").notify({
		    speed: 500,
		    expires: 3000
		});

	},
	
	pages: {
		
		classifications: function(){
			$('a.classification').live('click', function() {
				var class_id = $(this).attr('data-classification-id');
				var selected_events = $('input#selected_events').attr('value');
				var current_page = $('div#events').attr('data-action');
				
				if (selected_events.length > 0) {
					$('div.content').fadeTo(500, 0.4);
					Snorby.helpers.remove_click_events(true);

					$.post('/events/classify', {events: selected_events, classification: class_id}, function() {
						
						if (current_page == "index") {
							clear_selected_events();
							$.getScript('/events');
						} else if (current_page == "queue") {
							clear_selected_events();
							$.getScript('/events/queue');
						};

						flash_message.push({type: 'success', message: "Event(s) Classified Successfully"});
						
					});
					
				} else {
					flash_message.push({type: 'error', message: "Please Select Events To Perform This Action"});
					flash();
				};
				
				return false;
			});
		},
		
		events: function(){
			
			$('div.create-favorite.enabled').live('click', function() {
				var sid = $(this).parents('li.event').attr('data-event-sid');
				var cid = $(this).parents('li.event').attr('data-event-cid');
				
				$(this).removeClass('create-favorite').addClass('destroy-favorite');
				$.post('/events/favorite', { sid: sid, cid: cid });
				
				var count = new Queue();
				count.up();
				
				return false;
			});
			
			$('div.destroy-favorite.enabled').live('click', function() {
				var sid = $(this).parents('li.event').attr('data-event-sid');
				var cid = $(this).parents('li.event').attr('data-event-cid');
				var action = $('div#events').attr('data-action');
				
				$(this).removeClass('destroy-favorite').addClass('create-favorite');
				$.post('/events/favorite', { sid: sid, cid: cid });
				
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
						});
					} else {
						$('li.event div.event-data').slideUp('fast');
						current_row.slideDown('fast');
					};
				} else {
					
					check_box.hide();
					$('li.event div.event-data').slideUp('fast');
					parent_row.find('div.select').append("<img alt='laoding' src='/images/icons/loading.gif' class='select-loading'>");
					$.get('/events/show/'+sid+'/'+cid, function (data) {
						Snorby.helpers.remove_click_events(false);

						$('.select-loading').remove();
						check_box.show();
						
						current_row.html(Snorby.templates.event_data(data));
						current_row.attr('data', true);		
						current_row.slideDown('fast');
					});
					
				};
				
				return false;
			});

			$('div.new_events').live('click', function() {
				$('#events ul.table div.content li').fadeIn('slow');
				$(this).remove();
				return false;
			});

		},
		
	},
	
	admin: function(){
		
		$('#severity-color-bg').ColorPicker({
			color: $('input#severity_bg_color').attr('value'),
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
				$('input#severity_bg_color').val('#'+hex);
				$('#severity-color-bg div').css('backgroundColor', '#' + hex);
			}
		});
		
		$('#severity-color-text').ColorPicker({
			color: $('input#severity_text_color').attr('value'),
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
				$('input#severity_text_color').val('#'+hex);
				$('#severity-color-text div').css('backgroundColor', '#' + hex);
			}
		});
	},
	
	templates: {
		
		flash: function(data){
			var template = " \
			<div class='{{type}}' id='flash_message' style='display:none;'> \
				<div class='message {{type}}'>{{message}}</div> \
			</div>";
			return Mustache.to_html(template, data);
		},
		
		event_data: function(data){
			var ip_data = Snorby.templates.ip_header(data);
			
			if (data.type === "tcp") {
				var title = "<div class='section-title'>TCP Header Information</div>";
				var ip_proto = Snorby.templates.tcp_header(data.proto);
			} else if (data.type === "udp") {
				var title = "<div class='section-title'>UDP Header Information</div>";
				console.log(data.proto);
				var ip_proto = Snorby.templates.udp_header(data.proto);
			} else {
				var title = "<div class='section-title'>ICMP Header Information</div>";
				var ip_proto = Snorby.templates.icmp_header(data.proto);
			};
			
			var template = " \
			<div class='event-data-holder'> \
				<div class='event-data-holder-inside'> \
					<div class='section-title'>IP Header Information</div> \
					<div class='ip'>"+ip_data+"</div> \
					"+title+" \
					<div class='proto'>"+ip_proto+"</div> \
					<div class='section-title'>Payload</div> \
					<div class='round payload-ascii' style='display:none;'><pre class='round'>"+data.payload+"</pre></div> \
					<div class='round payload'><pre class='round'>"+data.payload_html+"</pre></div> \
					<div class='section-title'>Notes</div> \
					<div class='notes'> \
					</div> \
				</div> \
			</div> \
			"
			return Mustache.to_html(template, data);
		},
		
		icmp_header: function(data){
			var icmp = " \
			<table class='ip-header' border='0' cellspacing='0' cellpadding='0'> \
				<tr> \
					<th class='first'>Type</th> \
					<th>Code</th> \
					<th>Csum</th> \
					<th>ID</th> \
					<th class='last'>SEQ</th> \
				</tr> \
				<tbody> \
					<tr> \
						<td class='first'>{{icmp_type}}</td> \
						<td>{{icmp_code}}</td> \
						<td>{{icmp_csum}}</td> \
						<td>{{icmp_id}}</td> \
						<td class='last'>{{icmp_seq}}</td> \
					</tr> \
				</tbody> \
			</table>"
			return Mustache.to_html(icmp, data);
		},
		
		tcp_header: function(data){
			var tcp = " \
			<table class='ip-header' border='0' cellspacing='0' cellpadding='0'> \
				<tr> \
					<th class='first'>Src Port</th> \
					<th>Dst Port</th> \
					<th>Seq</th> \
					<th>Ack</th> \
					<th>Off</th> \
					<th>Res</th> \
					<th>Flags</th> \
					<th>Win</th> \
					<th>Csum</th> \
					<th class='last'>URP</th> \
				</tr> \
				<tbody> \
					<tr> \
						<td class='first'>{{tcp_sport}}</td> \
						<td>{{tcp_dport}}</td> \
						<td>{{tcp_seq}}</td> \
						<td>{{tcp_ack}}</td> \
						<td>{{tcp_off}}</td> \
						<td>{{tcp_res}}</td> \
						<td>{{tcp_flags}}</td> \
						<td>{{tcp_win}}</td> \
						<td>{{tcp_csum}}</td> \
						<td class='last'>{{tcp_urp}}</td> \
					</tr> \
				</tbody> \
			</table>"
			return Mustache.to_html(tcp, data);
		},
		
		udp_header: function(data){
			var udp = " \
			<table class='ip-header' border='0' cellspacing='0' cellpadding='0'> \
				<tr> \
					<th class='first'>Src Port</th> \
					<th>Dst Port</th> \
					<th>Len</th> \
					<th class='last'>Csum</th> \
				</tr> \
				<tbody> \
					<tr> \
						<td class='first'>{{udp_sport}}</td> \
						<td>{{udp_dport}}</td> \
						<td>{{udp_len}}</td> \
						<td class='last'>{{udp_csum}}</td> \
					</tr> \
				</tbody> \
			</table>"
			return Mustache.to_html(udp, data);
		},
		
		ip_header: function(data){
			var ip = " \
			<table class='ip-header' border='0' cellspacing='0' cellpadding='0'> \
				<tr> \
					<th class='first'>Src</th> \
					<th>Dst</th> \
					<th>Ver</th> \
					<th>Hlen</th> \
					<th>Tos</th> \
					<th>Len</th> \
					<th>ID</th> \
					<th>Flags</th> \
					<th>Off</th> \
					<th>TTL</th> \
					<th>Proto</th> \
					<th class='last'>Csum</th> \
				</tr> \
				<tbody> \
					<tr> \
						<td class='first'>{{dst_ip}}</td> \
						<td>{{src_ip}}</td> \
						{{#ip}} \
						<td>{{ip_ver}}</td> \
						<td>{{ip_hlen}}</td> \
						<td>{{ip_tos}}</td> \
						<td>{{ip_len}}</td> \
						<td>{{ip_id}}</td> \
						<td>{{ip_flags}}</td> \
						<td>{{ip_off}}</td> \
						<td>{{ip_ttl}}</td> \
						<td>{{ip_proto}}</td> \
						<td class='last'>{{ip_csum}}</td> \
						{{/ip}} \
					</tr> \
				</tbody> \
			</table>"
			return Mustache.to_html(ip, data);
		},
		
		event_table: function(data){
			var template = " \
			{{#events}} \
			<li id='event_{{sid}}{{cid}}' class='event' style='display:none;' data-event-id='{{sid}}{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<div class='row'> \
					<div class='select small'><input class='event-selector' id='event-selector' name='event-selector' type='checkbox'></div> \
					<div class='important small'><div class='create-favorite enabled'></div></div> \
					<div class='severity small'><span class='severity sev{{severity}}'>{{severity}}</span></div> \
					<div class='click sensor address'>{{hostname}}</div> \
					<div class='click src_ip address'>{{ip_src}}</div> \
					<div class='click dst_ip address'>{{ip_dst}}</div> \
					<div class='click signature'>{{message}}</div> \
					<div class='click timestamp'>{{timestamp}}</div> \
				</div> \
				<div style='display:none;' class='event-data' data='false'></div> \
			</li> \
			{{/events}}"
			
			return Mustache.to_html(template, data);
		},
	},
	
	notification: function(message){
		$('#growl').notify("create", message,{
		    expires: 3000,
		    speed: 500
		});
	},
	
	helpers: {
		
		dropdown: function(){
			
			$('dl.drop-down-menu dd a').live('click', function() {
				$('dl.drop-down-menu').fadeOut('slow');
				return true;
			});
			
			$('a.has_dropdown').live('click', function() {
				var id = $(this).attr('id');
				var dropdown = $(this).parents('li').find('dl#'+id);
				
				$('dl.drop-down-menu').each(function(index) {
				  
					if (id === $(this).attr('id')) {
						
						if ($(this).is(':visible')) {
							dropdown.slideUp('fast');
						} else {
							dropdown.slideDown('fast');
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
				
				if (!$(this).hasClass('more')) {
					
					var current_width = $(this).width();
					if (current_width < 16) { var current_width = 16 };
					$(this).addClass('loading').css('width', current_width);
					$('div.content').fadeTo(500, 0.4);
					Snorby.helpers.remove_click_events(true);
					$.getScript($(this).find('a').attr('href'));
					
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
			
			//console.log("XHR Response: " + JSON.stringify(xhr));
		});
		
	}
	
}

jQuery(document).ready(function($) {
	
	Snorby.setup();
	Snorby.admin();
	Snorby.callbacks();
	
	Snorby.helpers.dropdown();
	Snorby.helpers.persistence_selections();
	Snorby.helpers.pagenation();
	
	Snorby.pages.classifications();
	Snorby.pages.events();
	
});
