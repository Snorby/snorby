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

var Snorby = {
	
	setup: function(){

		$("#growl").notify({
		    speed: 500,
		    expires: 3000
		});

	},
	
	pages: {
		
		events: function(){

			// Row Select
			// $('table tbody.events tr.event').live('click', function() {
			// 	var sid = $(this).attr('data-event-sid');
			// 	var cid = $(this).attr('data-event-cid');
			// 	var current_row = $(this);
			// 	
			// 	if ($('table tbody.events tr#event-data-'+sid+''+cid).is(':visible')) {
			// 		$('table tbody.events tr#event-data-'+sid+''+cid+' div.event-data-holder').slideUp('fast', function () {
			// 			$('table tbody.events tr#event-data-'+sid+''+cid).hide();
			// 		});
			// 	} else {
			// 		$.get('/events/show/'+sid+'/'+cid, function (data) {
			// 			current_row.after(Snorby.templates.event_data(data));
			// 			$('table tbody.events tr#event-data-'+sid+''+cid+' div.event-data-holder').slideDown('fast');
			// 		});
			// 	};
			// 	
			// 	return false;
			// });

			$('div.new_events').live('click', function() {
				$('#events ul.table div.content li').fadeIn('slow');
				$(this).remove();
				return false;
			});

		},
		
	},
	
	admin: function(){
		$('#severity-color-bg').ColorPicker({
			color: '#0000ff',
			onShow: function (colpkr) {
				$(colpkr).fadeIn(500);
				return false;
			},
			onHide: function (colpkr) {
				$(colpkr).fadeOut(500);
				return false;
			},
			onSubmit: function(hsb, hex, rgb, el) {
					$.post('/admin/severity', {id: 3, severity: { text_color: '#' + hex}});
					$(el).ColorPickerHide();
			},
			onChange: function (hsb, hex, rgb) {
				$('#severity-color-bg div').css('backgroundColor', '#' + hex);
			}
		});
		
		$('#severity-color-text').ColorPicker({
			color: '#0000ff',
			onShow: function (colpkr) {
				$(colpkr).fadeIn(500);
				return false;
			},
			onHide: function (colpkr) {
				$(colpkr).fadeOut(500);				
				return false;
			},
			onSubmit: function(hsb, hex, rgb, el) {
					$.post('/admin/severity', {id: 3, severity: { bg_color: '#' + hex}});
					$(el).ColorPickerHide();
			},
			onChange: function (hsb, hex, rgb) {
				$('#severity-color-text div').css('backgroundColor', '#' + hex);
			}
		});
	},
	
	templates: {
		
		event_data: function(data){
			var template = " \
			<tr id='event-data-{{sid}}{{cid}}' class='event-data' data-event-id='{{sid}}{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<td class='first last' colspan='7'> \
				 	<div class='event-data-holder' style='display:none;'> \
						<pre>{{payload}}</pre>\
					</div> \
				</td> \
			</tr>"
			return Mustache.to_html(template, data);
		},
		
		event_table: function(data){
			var template = " \
			{{#events}} \
			<li id='event_{{sid}}{{cid}}' class='event' style='display:none;' data-event-id='{{sid}}{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<div class='select small'><input class='event-selector' id='event-selector' name='event-selector' type='checkbox'></div> \
				<div class='important small'><img alt='Star-empty' src='/images/icons/star-empty.png'></div> \
				<div class='severity small'><span class='severity sev{{severity}}'>{{severity}}</span></div> \
				<div class='sensor address'>{{hostname}}</div> \
				<div class='src_ip address'>{{ip_src}}</div> \
				<div class='dst_ip address'>{{ip_dst}}</div> \
				<div class='signature'>{{message}}</div> \
				<div class='timestamp'>{{timestamp}}</div> \
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
		
	}
	
}

jQuery(document).ready(function($) {
	
	Snorby.setup();
	Snorby.admin();
	Snorby.pages.events();
	
});
