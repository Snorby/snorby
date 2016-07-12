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


$.fn.buttonLoading = function() {
  var width = $(this).outerWidth(true) - 2;
  var height = $(this).outerHeight(false) - 2;

  $(this).addClass('loading').css({
    width: width,
    height: height
  });
};

$.deparam = jq_deparam = function( params, coerce ) {
  var obj = {};
  var coerce_types = { 'true': !0, 'false': !1, 'null': null };

  $.each( params.replace( /\+/g, ' ' ).split( '&' ), function(j,v){
    var param = v.split( '=' ),
      key = decodeURIComponent( param[0] ),
      val,
      cur = obj,
      i = 0,

      keys = key.split( '][' ),
      keys_last = keys.length - 1;

    if ( /\[/.test( keys[0] ) && /\]$/.test( keys[ keys_last ] ) ) {
      keys[ keys_last ] = keys[ keys_last ].replace( /\]$/, '' );

      keys = keys.shift().split('[').concat( keys );

      keys_last = keys.length - 1;
    } else {
      keys_last = 0;
    }

    if ( param.length === 2 ) {
      val = decodeURIComponent( param[1] );

      if ( coerce ) {
        val = val && !isNaN(val)            ? +val              // number
          : val === 'undefined'             ? undefined         // undefined
          : coerce_types[val] !== undefined ? coerce_types[val] // true, false, null
          : val;                                                // string
      }

      if ( keys_last ) {
        for ( ; i <= keys_last; i++ ) {
          key = keys[i] === '' ? cur.length : keys[i];
          cur = cur[key] = i < keys_last
            ? cur[key] || ( keys[i+1] && isNaN( keys[i+1] ) ? {} : [] )
            : val;
        }

      } else {

        if ( $.isArray( obj[key] ) ) {
          obj[key].push( val );

        } else if ( obj[key] !== undefined ) {
          obj[key] = [ obj[key], val ];

        } else {
          obj[key] = val;
        }
      }

    } else if ( key ) {
      obj[key] = coerce
        ? undefined
        : '';
    }
  });

  return obj;
};

function post_to_url(path, params, method) {
  method = method || "post";

  var form = document.createElement("form");
  form.setAttribute("method", method);
  form.setAttribute("action", path);

  for(var key in params) {
    if (params.hasOwnProperty(key)) {
      var hiddenField = document.createElement("input");
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("name", key);

      var value = params[key];
      if (typeof value === "object") {
        hiddenField.setAttribute("value", JSON.stringify(value));
      } else if (typeof value === "string") {
        hiddenField.setAttribute("value", value);
      } else if (typeof value === "boolean") {
        hiddenField.setAttribute("value", value);
      };

      form.appendChild(hiddenField);
    };
  };

  document.body.appendChild(form);
  form.submit();
};

var SearchRule;
SearchRule = function() {

  function SearchRule(selectData, callback) {
    var self = this;
    self.html = Handlebars.templates['search-rule']({});
    var selectData = JSON.parse(selectData);
    self.columns = selectData.columns;
    self.operators = selectData.operators;

    self.selectData = selectData;

    self.classifications = selectData.classifications;
    self.sensors = selectData.sensors;
    self.users = selectData.users;
    self.signatures = selectData.signatures;
    self.severities = selectData.severities;
    self.protocol = selectData.protocol;
    self.has_note = selectData.has_note;

    self.init();
    return self;
  };

  SearchRule.prototype = {

    init: function(callback) {
      var self = this;
      var width = "368px";

      self.sensors_html = Handlebars.templates['select']({
        name: "sensors-select",
        width: width,
        multiple: false,
        data: self.sensors
      });

      self.classifications_html = Handlebars.templates['select']({
        name: "classifications-select",
        width: width,
        data: self.classifications
      });

      self.severity_html = Handlebars.templates['select']({
        name: "severities-select",
        width: width,
        data: self.severities
      });

      console.log(self);

      self.has_note_html = Handlebars.templates['select']({
        name: "has-note-select",
        width: width,
        data: self.has_note
      });

      self.signatures_html = Handlebars.templates['select']({
        name: "signatures-select",
        width: width,
        data: self.signatures
      });

      self.users_html = Handlebars.templates['select']({
        name: "users-select",
        width: width,
        data: self.users
      });

      self.protocol_html = Handlebars.templates['select']({
        name: "protocol-select",
        width: width,
        data: self.protocol
      });

      self.columns_html = Handlebars.templates['select']({
        name: "column-select",
        placeholder: "Choose a query term...",
        data: {
          value: self.columns
        }
      });

      self.operators_html = function($html, data) {
        var select = Handlebars.templates['select']({
          name: "operators-select",
          data: {
            value: data
          }
        });

        $html.find('div.operator-select').html(select);
      };

      self.datetime_picker = function(that) {
        that.datetimepicker({
        	timeFormat: 'hh:mm:ss',
          dateFormat: 'yy-mm-dd',
          numberOfMonths: 1,
          showSecond: true,
	        separator: ' '
        });
      };

    },

    searchUI: function(data, callback) {
      var self = this;
      $('#content #title').after(Handlebars.templates['search'](data));

      $('.search-content-add').live('click', function(e) {
        e.preventDefault();
        self.add(this);
      });

      $('.search-content-remove').live('click', function(e) {
        e.preventDefault();
        self.remove(this);
      });

      $('div.search-content-enable input').live('click', function() {
        if ($(this).is(':checked')) {
          $(this)
          .parents('.search-content-box')
          .find('.value *, .operator-select *, .column-select *')
          .attr('disabled', false).css('opacity', 1);
        } else {
          $(this)
          .parents('.search-content-box')
          .find('.value *, .operator-select *, .column-select *')
          .attr('disabled', true).css('opacity', 0.8);
        };

        $('.add_chosen').trigger("liszt:updated");
      });

      $('button.submit-search').live('click', function(e) {
        e.preventDefault();
        self.submit();
      });

      $('#content #title').on('click', 'a.reset-search-form', function(e) {
        e.preventDefault();

        $('.rules').empty();

        self.add();
        self.add();
        self.add();
      });

      if (callback && (typeof callback === "function")) {
        callback();
      };
    },

    add: function(that, newOptions, callback) {
      var self = this;
      var options = {};

      if (options && (typeof options === "object")) {
        options = newOptions;
      };

      var $html = $(self.html);
      $html.find('div.column-select').html(self.columns_html);

      if (that && (typeof that === "object")) {
        $(that).parents('.search-content-box').after($html);
      } else {
        $('.rules').append($html);
      };

      $html.find('.add_chosen')
      .chosen({allow_single_deselect: true})
      .change(function(event, data) {
        var value = $(this).val();
        var that = $(this).parents('.search-content-box');

        if (value === "signature") {
          that.find('.value').html(self.signatures_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "signature_name") {
          that.find('.value').html('<input class="search-content-value" placeholder="Enter search value" name="" type="text">');
          self.operators_html($html, self.operators.contains);
        } else if (value === "sensor") {
          that.find('.value').html(self.sensors_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "classification") {
          that.find('.value').html(self.classifications_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "has_note") {
          that.find('.value').html(self.has_note_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "user") {
          that.find('.value').html(self.users_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "severity") {
          that.find('.value').html(self.severity_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "protocol") {
          that.find('.value').html(self.protocol_html);
          self.operators_html($html, self.operators.text_input);
        } else if (value === "start_time") {
          that.find('.value').html('<input id="time-'+ new Date().getTime() +'" class="search-content-value" placeholder="Enter search value" name="" type="text">');
          self.datetime_picker(that.find('.value input:first'))
          self.operators_html($html, self.operators.datetime);
        } else if (value === "end_time") {
          that.find('.value').html('<input id="time-'+ new Date().getTime() +'" class="search-content-value" placeholder="Enter search value" name="" type="text">');
          self.datetime_picker(that.find('.value input:first'))
          self.operators_html($html, self.operators.datetime);
        } else if (value === "payload") {
          that.find('.value').html('<input class="search-content-value" placeholder="Enter search value" name="" type="text">');
          self.operators_html($html, self.operators.more_text_input);
        } else if (value === "") {
          that.find('.value').html('<input class="search-content-value" placeholder="Enter search value" name="" type="text">');
          self.operators_html($html, self.operators.text_input);
        } else {
          that.find('.value').html('<input class="search-content-value" placeholder="Enter search value" name="" type="text">');
          self.operators_html($html, self.operators.text_input);
        };

        that.find('.add_chosen').chosen({
          allow_single_deselect: true
        });

        if (callback && (typeof callback === "function")) {
          callback(that);
        };

        that.trigger('snorby:search:change');
      });

      $('.search-content-box:first')
      .find('.search-content-remove')
      .css('opacity', 1)
      .unbind('hover')
      .unbind('mouseover');

      return $html;
    },

    remove: function(that) {
      var self = this;
      if ($('.search-content-box').length > 2) {
        $(that).parents('.search-content-box').remove();
      } else if ($('.search-content-box').length == 2) {
        $(that).parents('.search-content-box').remove();

        $('.search-content-box:first')
        .find('.search-content-remove')
        .css('opacity', 0.4)
        .attr('title', 'You must have at least one search rule.')
        .tipsy({
				  gravity: 's'
			  });
      };
    },

    pack: function() {
      var self = this;
      var matchAll = false;

      if ($('#search select.global-match-setting').val() === "all") {
        matchAll = true;
      };

      var json = {
        match_all: matchAll,
        items: {}
      };

      $('.search-content-box').each(function(index, item) {
        var enabled = $(item).find('.search-content-enable input').is(':checked');
        var column = $(item).find('.column-select select').val();
        var operator = $(item).find('.operator-select select').val();
        var value = $(item).find('.value input, .value select').val();

        if ((column !== "") || (value !== "")) {
          json.items[index] = {
            column: column,
            operator: operator,
            value: value,
            enabled: enabled
          };
        };
      });

      return json;
    },

    submit: function(callback, otherOptions) {
      var self = this;
      var search = self.pack();

      if (typeof otherOptions !== "object") {
        otherOptions = {};
      };

      var update_url = function() {
        if (history && history.pushState) {
          history.pushState(null, document.title, baseuri + '/results');
        };
      };

      if (callback && (typeof callback === "function")) {
        callback(search, self);
      };

      if (search && !$.isEmptyObject(search.items)) {
        if (otherOptions.search_id) {
          post_to_url(baseuri + '/results', {
            match_all: search.match_all,
            search: search.items,
            title: otherOptions.title,
            search_id: ""+otherOptions.search_id+"",
            authenticity_token: csrf
          });
        } else {
          post_to_url(baseuri + '/results', {
            match_all: search.match_all,
            search: search.items,
            authenticity_token: csrf
          });
        };
      } else {
        flash_message.push({type: 'error', message: "You cannot submit all empty search rules."});flash();
      };
    },

    build: function(search) {
      var self = this;

      if (typeof search === "string") {
        var data = JSON.parse(search);
      } else if (typeof search === "object") {
        var data = search;
      } else {
        var data = {};
      };

      if (data.items) {
       var rules = data.items;
      } else if (data.search) {
        var rules = data.search;
      } else {
        var rules = {};
      };

      if (data.match_all && data.match_all === "false") {
       $('select.global-match-setting option[value="any"]').attr('selected', 'selected');
      } else {
        $('select.global-match-setting option[value="all"]').attr('selected', 'selected');
      };

      for (id in rules) {
        var item = rules[id];

        var rule = self.add(false, {});

        var column = rule.find('div.column-select select');

        rule.bind('snorby:search:change', function() {
          var operator = $(this).find('div.operator-select select');
          var value = $(this).find('div.value select, div.value input');

          operator.find("option[value='"+item.operator+"']").attr('selected', 'selected');
          operator.trigger("liszt:updated");
          value.attr('value', item.value);

          rule.unbind('snorby:search:change');
        });

        rule.attr('data-rule-id', id);

        column.find("option[value='"+item.column+"']").attr('selected','selected');
        column.trigger("liszt:updated").trigger('change');

        if (item.enabled === "false") {
          rule.find('div.search-content-enable input').attr('checked', false);
          rule.find('.value *, .operator-select *, .column-select *')
          .attr('disabled', true).css('opacity', 0.8);
        };
      };

      $('.rules .add_chosen').trigger("liszt:updated");
    },

  };

  return SearchRule;
}();

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
  if ($('div#sessions-event-count-selected').length > 0) {
    $('div#sessions-event-count-selected').data('count', 0);
  };
	return false;
};

function set_classification (class_id) {
	var selected_events = $('input#selected_events').attr('value');
	var current_page = $('div#events').attr('data-action');
	var current_page_number = $('div#events').attr('data-page');

  var direction = $('div#events').attr('data-direction');
  var sort = $('div#events').attr('data-sort');

  var classify_events = function() {
    $.post(baseuri + '/events/classify', {events: selected_events, classification: class_id, authenticity_token: csrf}, function() {
      if (current_page == "index") {
        clear_selected_events();
        $.getScript(baseuri + '/events?direction='+direction+'&sort='+sort+'&page=' + current_page_number);
      } else if (current_page == "queue") {
        clear_selected_events();
        $.getScript(baseuri + '/events/queue?direction='+direction+'&sort='+sort+'&page=' + current_page_number);
      } else if (current_page == "history") {
        clear_selected_events();
        $.getScript(baseuri + '/events/history?direction='+direction+'&sort='+sort+'&page=' + current_page_number);
      } else if (current_page == "results") {
        clear_selected_events();

        if ($('div#search-params').length > 0) {

          var search_data = JSON.parse($('div#search-params').text());

          var direction = $('div#results').attr('data-direction');
          var sort = $('div#results').attr('data-sort');

          if (search_data) {
            $.ajax({
              url: $('input#current_url').val(),
              global: false,
              dataType: 'script',
              data: {
                match_all: search_data.match_all,
                search: search_data.search,
                authenticity_token: csrf,
                direction: direction,
                sort: sort
              },
              cache: false,
              type: 'POST',
              success: function(data) {
                $('div.content').fadeTo(500, 1);
                Snorby.helpers.remove_click_events(false);
                Snorby.helpers.recheck_selected_events();

                if (history && history.pushState) {
                  history.pushState(null, document.title, $('input#current_url').val());
                };
                $.scrollTo('#header', 500);
              }
            });
          };

        };

      } else {
        // clear_selected_events();
        // $.getScript(baseuri + '/events');
      };
      flash_message.push({type: 'success', message: "Event(s) Classified Successfully"});
    });
  };

	if (selected_events.length > 0) {
		$('div.content').fadeTo(500, 0.4);
		Snorby.helpers.remove_click_events(true);

    if ($('#events').data('action') === "sessions") {

      var count = 0;
      if ($('div#sessions-event-count-selected').length > 0) {
        count = $('div#sessions-event-count-selected').data('count');
      };

      $.post(baseuri + '/events/classify_sessions',{
        events: selected_events,
        classification: class_id,
        authenticity_token: csrf
      }, function(data) {
        clear_selected_events();
        $.getScript(baseuri + '/events/sessions?direction=' + direction + '&sort=' + sort + '&page=' + current_page_number);

        flash_message.push({type: 'success', message: "Event(s) Classified Successfully ("+count+" sessions)"});
      });

    } else {
      classify_events();
    };

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
};

function fetch_last_event(callback) {
  $.ajax({
    url: baseuri + '/events/last',
    dataType: 'json',
    type: 'GET',
    global: false,
    cache: false,
    success: function(data) {
      if (data && (data.time)) {
        $('div#wrapper').attr({last_event: data.time});
        callback(data.time);
      };
    }
  });
};

function monitor_events(prepend_events) {

  $("#growl").notify({
      speed: 500,
      expires: 5000
  });

  fetch_last_event(function(time) {
    setInterval (function () {
      new_event_check(prepend_events);
    }, 50000);
  });

};

function new_event_check(prepend_events) {
  $.ajax({
    url: baseuri + '/events/last',
    dataType: 'json',
    type: 'GET',
    global: false,
    cache: false,
    success: function(data) {
      var old_id = $('div#wrapper').attr('last_event');

      var page = parseInt($('.pager li.active a').html());

      if (old_id != data.time) {
        $.ajax({
          url: baseuri + '/events/since',
          data: { timestamp: old_id },
          dataType: 'json',
          type: 'GET',
          global: false,
          cache: false,
          success: function(newEvents) {
            if (newEvents.events && newEvents.events.length != 0) {

              if (prepend_events) {
                if (page <= '1') {

                  if ($('div.new_events').length == 0) {

                    $('#events').prepend('<div class="note new_events"><strong class="new_event_count">'+newEvents.events.length+'</strong> New Events Are Available Click here To View Them.</div>');

                  } else {

                    var new_count = parseInt($('#events div.new_events strong.new_event_count').html()) + newEvents.events.length;
                    $('#events div.new_events').html('<strong class="new_event_count">'+new_count+'</strong> New Events Are Available Click here To View Them.');

                  };

                  $('#events ul.table div.content').prepend(Snorby.templates.event_table(newEvents));
                };
              };

              Snorby.notification({title: 'New Events', text: newEvents.events.length + ' Events Added.'});
            };
          }
        });

        $('div#wrapper').attr('last_event', data.time);
      };
    }
  });
};

function update_note_count (event_id, data) {

	var event_row = $('li#'+event_id+' div.row div.timestamp');
	var notes_count = event_row.find('span.notes-count');

	var template = '<span class="add_tipsy round notes-count" title="{{notes_count_in_words}}"><img alt="Notes" height="16" src="' + baseuri + '/images/icons/notes.png" width="16"></span>'
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

  file: {
    upload_asset_csv: function(){
      var self = $('#bulk-upload-form')
      self.submit();
    }
  },

  submitAssetName: function() {
    var self = $('form.update-asset-name-form');
    var q = self.formParams();
    var params = {};
    var errors = 0;

    $('button.update-asset-name-submit-button').attr('disabled', true).find('span').text('Loading...');

    if (q.id) {
      params.id = q.id;
    };

    if (q.ip_address) {
      params.ip_address = q.ip_address;
    } else {
      errors++;
    };

    if (q.name) {
      params.name = q.name;
    } else {
      errors++;
      $('input#edit-asset-name-title').addClass('error');
    };

    if (q.global) {
      params.global = true;
    } else {
      params.global = false;
      if (q.agents) {
        params.sensors = q.agents;
      } else {
        errors++;
        $('#edit-asset-name-agent-select_chzn .chzn-choices').addClass('error');
      };
    };

    if (Snorby.submitAjaxRequestAssetName) {
      Snorby.submitAjaxRequestAssetName.abort();
    };

    if (errors <= 0) {
      Snorby.submitAjaxRequestAssetName = $.ajax({
        url: baseuri + '/asset_names/add',
        dataType: "json",
        data: params,
        type: "post",
        success: function(data) {
          $.limpClose();
          var agent_ids = [];

          for (var i = 0; i < data.asset_name.sensors.length; i += 1) {
            agent_ids.push(parseInt(data.asset_name.sensors[i]));
          }

          $('ul.table div.content li.event div.address').each(function() {
            var self = $(this).parents('li.event');
            var address = $('div.asset-name', this);
            var addr = $(this).attr('data-address');
            var id = parseInt(self.attr('data-agent-id'));

            if (addr === data.asset_name.ip_address) {

              self.find('dd a.edit-asset-name').each(function() {
                var ip = $(this).attr('data-ip_address');
                if (addr === ip) {
                  $(this).attr('data-asset_agent_ids', agent_ids);
                  $(this).attr('data-asset_global', data.asset_name.global);
                  $(this).attr('data-asset_name', data.asset_name.name);
                };
              });

              if (data.asset_name.global) {
                address.text(data.asset_name.name);
              } else {
                if ($.inArray(id, agent_ids) !== -1) {
                  address.text(data.asset_name.name);
                } else {
                  address.text(data.asset_name.ip_address);
                };
              };
            };

          });
        },
        error: function(a,b,c) {
          $('button.update-asset-name-submit-button').attr('disabled', false).find('span').text('Update');
          flash_message.push({
            type: 'error',
            message: "Error: " + c
          });
          flash();
        }
      });
    } else {
      $('button.update-asset-name-submit-button').attr('disabled', false).find('span').text('Update');
      flash_message.push({
        type: 'error',
        message: "Please make sure all form fields are correctly populated."
      });
      flash();
    }; // no errors

  },

  sessionViewUpdate: function(params, timeout) {
    var delay = timeout || 20000;

    Snorby.sessionViewUpdateClear();

    Snorby.sessionViewUpdateInterval = setInterval(function() {
      if (Snorby.sessionViewUpdateRequest) {
        Snorby.sessionViewUpdateRequest.abort();
      };

      Snorby.sessionViewUpdateRequest = $.ajax({
        url: baseuri + '/events/sessions.json',
        data: {
          sort:  params.sort || 'desc',
          direction: params.direction || 'timestamp',
          page: params.page || 0
        },
        global: false,
        type: 'get',
        dataType: 'json',
        success: function(data) {
          if (data.hasOwnProperty('events')) {
            for (var i = 0; i < data.events.length; i += 1) {
              var event = data.events[i];
              var row = $('li.event[data-session-id="'+event.ip_src+'_'+event.ip_dst+'_'+event.sig_id+'"]');

              if (row.length > 0) {
                if (parseInt(row.find('div.session-count').attr('data-sessions')) !== event.session_count) {

                  row.find('div.session-count')
                  .attr('data-sessions', event.session_count).find('span')
                  .html(event.session_count)
                  .effect("highlight", {}, 3000);

                  row.find('div.timestamp b')
                  .attr('title', "Event ID: " + event.sid + "." + event.cid + " " + event.datetime)
                  .html(event.timestamp);
                };
              } else {
                if (parseInt(params.page) < 1) {
                  var html = Snorby.puts('session-event-row', event);
                  $('div#events ul.table div.content').prepend(html);
                };
              };
            } // for loop

            // $('div#events ul.table div.content li').sortElements(function(a, b) {
            // });
          };
        }
      });
    }, delay);
  },

  sessionViewUpdateClear: function() {
    if (Snorby.sessionViewUpdateInterval) {
      clearInterval(Snorby.sessionViewUpdateInterval);
    };

    if (Snorby.sessionViewUpdateRequest) {
      Snorby.sessionViewUpdateRequest.abort();
    };
  },

  colorPicker: function() {

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



  snorbyCloudBoxOptions: {
    cache: true,
    round: 5,
    loading: true,
    animation: 'none',
    distance: 10,
    overlayClick: true,
    enableEscapeButton: true,
    dataType: 'html',
    centerOnResize: true,
    closeButton: true,
    shadow: '0 0 30px rgba(0,0,0,1)',
    style: {
      background: 'rgba(36,36,36,0.9)',
      border: '1px solid rgba(0,0,0,0.9)',
      padding: '0',
      width: '700px'
    },
    inside: {
      background: 'transparent',
      padding: '0',
      display: 'block',
      border: 'none',
      overflow: 'visible'
    },
    overlay: {
      background: '#000',
      opacity: 0.9
    },
    onOpen: function() {
      // disable_scroll();
      // if (Snorby.escBind) {
        // $(document).unbind('keydown', Snorby.escBind);
      // };
      $('body').addClass('stop-scrolling');
      $('body').bind('touchmove', function(e){
        e.preventDefault();
      });

      $('dl#event-sub-menu').hide();
    },
    afterOpen: function(limp, html) {
      Snorby.eventCloseHotkeys(false);
      // $('.add-chosen').chosen();
      // $(".add-chosen").trigger("liszt:updated");
      if (Snorby.escBind) {
        $(document).unbind('keydown', Snorby.escBind);
      };

      html.find('#snorbybox-content .add_chosen').chosen({
        allow_single_deselect: true
      });

      Snorby.colorPicker();

      $('img.recover, img.avatar, img.user-view-avatar, img.avatar-small, div.note-avatar-holder img').error(function(event) {
        $(this).attr("src", baseuri + "/images/default_avatar.png");
      });
    },
    afterClose: function() {
      Snorby.eventCloseHotkeys(true);

      if (Snorby.escBind) {
        $(document).bind('keydown', 'esc', Snorby.escBind);
      };

      // enable_scroll();
      $('body').removeClass('stop-scrolling');
      $('body').unbind('touchmove')
    },
    onTemplate: function(template, data, limp) {

      try {
        var $html = Snorby.puts(template, data);
        if ($html.length > 0) { return $html; }
        return false;
      } catch(e) {
        return false;
      }

    }
  },

  puts: function(name, data) {
    var self = this;

    if (Handlebars.templates.hasOwnProperty(name)) {
      var $html = $(Handlebars.templates[""+name+""](data));
    } else {
      var template = Handlebars.compile(name);
      var $html = template(data);
    }
    return $html;
  },

  box: function(template, data, args) {
    var self = this;

    $.limpClose();
    var options = $.extend({}, self.snorbyCloudBoxOptions, args);
    options.template = template;
    options.templateData = data;

    var box = $.limp(options);

    return box;
  },

	setup: function(){

		$('div#flash_message, div#flash_message > *').live('click', function() {
			$('div#flash_message').stop().fadeOut('fast');
		});

		$("#growl").notify({
		    speed: 500,
		    expires: 5000
		});

		$('.edit-sensor-name').editable(baseuri + "/sensors/update_name", {
			height: '20px',width: '180px',name: "name",
			indicator: '<img src="' + baseuri + '/images/icons/pager.gif">',
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
						$(document).trigger('limp.close');
						$.post(baseuri + '/events/email', $('form.email-event-information').serialize(), null, "script");
					};
				};
				return false;
			});

			$('button.request_packet_capture').live('click', function(e) {
		    e.preventDefault();
				if ($(this).attr('data-deepsee')) { $('form.request_packet_capture input#method').val('deepsee') };
				$.post(baseuri + '/events/request_packet_capture', $('form.request_packet_capture').serialize(), null, "script");
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
				$(document).trigger('limp.close');
				$.post(baseuri + '/events/mass_action', nform.serialize(), null, "script");
				return false;
			});

			$('button.create-notification').live('click', function(e) {
				e.preventDefault();
				var nform = $('form#new_notification');
				$.post(baseuri + '/notifications', nform.serialize(), null, "script");
				$(document).trigger('limp.close');
				return false;
			});

			$('button.cancel-snorbybox').live('click', function(e) {
				e.preventDefault();
				$(document).trigger('limp.close');
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
				$.getScript(baseuri + '/notes/' + note_id + '/edit');
				return false;
			});

			$('a.destroy-event-note').live('click', function(e) {
				e.preventDefault();
				var note = $(this).parents('div.event-note');
				var note_id = $(this).attr('data-note-id');

				if ( confirm("Are you sure you want to delete this note?") ) {
					$('div.notes').fadeTo(500, 0.4);
					$.post(baseuri + '/notes/destroy', { id: note_id, authenticity_token: csrf, '_method': 'delete' }, null, 'script');
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

					$.get(baseuri + '/notes/new', { sid: event_sid, cid: event_cid, authenticity_token: csrf}, null, 'script');
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

					$.post(baseuri + '/notes/create', { sid: event_sid, cid: event_cid, body: note_body, authenticity_token: csrf}, null, 'script');

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

      $('.snorbybox').limp({
        cache: true,
        round: 0,
        loading: true,
        animation: 'pop',
        enableEscapeButton: true,
        shadow: '0 1px 30px rgba(0,0,0,0.6)',
        style: {
          background: 'rgba(36,36,36,0.9)',
          border: '1px solid rgba(0,0,0,0.9)',
          padding: '5px',
          width: '700px'
        },
        inside: {
          border: '1px solid rgba(0,0,0,0.9)',
          padding: 0
        },
        overlay: {
          background: '#000',
          opacity: 0.6
        },
        onOpen: function() {
          Snorby.eventCloseHotkeys(false);
          $('body').addClass('stop-scrolling');
          $('body').bind('touchmove', function(e){
        e.preventDefault();
      });
          $('dl#event-sub-menu').hide();
        },
        afterOpen: function(limp, html) {

          html.find('#snorbybox-content .add_chosen').chosen({
            allow_single_deselect: true
          });
        },
        onClose: function() {
          Snorby.eventCloseHotkeys(true);
        },
        afterClose: function() {
          Snorby.eventCloseHotkeys(true);

          if (Snorby.escBind) {
            $(document).bind('keydown', 'esc', Snorby.escBind);
          };

          // enable_scroll();
          $('body').removeClass('stop-scrolling');
          $('body').unbind('touchmove')
        },
      });

			$('div.create-favorite.enabled').live('click', function() {
				var sid = $(this).parents('li.event').attr('data-event-sid');
				var cid = $(this).parents('li.event').attr('data-event-cid');

				$(this).removeClass('create-favorite').addClass('destroy-favorite');
				$.post(baseuri + '/events/favorite', { sid: sid, cid: cid, authenticity_token: csrf});

				var count = new Queue();
				count.up();

				return false;
			});

			$('div.destroy-favorite.enabled').live('click', function() {
				var sid = $(this).parents('li.event').attr('data-event-sid');
				var cid = $(this).parents('li.event').attr('data-event-cid');
				var action = $('div#events').attr('data-action');

				$(this).removeClass('destroy-favorite').addClass('create-favorite');
				$.post(baseuri + '/events/favorite', { sid: sid, cid: cid, authenticity_token: csrf});

				var count = new Queue();
				count.down();

				if (action == 'queue') {
					$('div.content').fadeTo(500, 0.4);
					Snorby.helpers.remove_click_events(true);
					$('div.destroy-favorite').removeClass('enabled').css('cursor', 'default');
					$.get(baseuri + '/events/queue', null, null, "script");
				};

				return false;
			});

			$('input.event-select-all').live('change', function() {
        var $item = $('ul.table div.content li.event input#event-selector');

        if ($(this).is(':checked')) {
					$item.attr('checked', true);
          $item.trigger('change');
				} else {
					$item.removeAttr('checked');
          $item.trigger('change');
				};

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
					parent_row.find('div.select').append("<img alt='loading' src='" + baseuri + "/images/icons/loading.gif' class='select-loading'>");

          var open_event_url = baseuri + '/events/show/'+sid+'/'+cid;

          if ($('div#events').data('action') === "sessions") {
            open_event_url = baseuri + '/events/show/'+sid+'/'+cid+'?sessions=true';
          };

					$.get(open_event_url, function () {

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
					window.location = baseuri + '/events'
				} else {
					$('#events ul.table div.content li').fadeIn('slow');
				};
				return false;
			});

		},

	},

  eventCloseHotkeys: function(bind) {
    if (bind) {
			$(document).bind('keydown', '1', Snorby.hotKeyCallback.Sev1);
      $(document).bind('keydown', '2', Snorby.hotKeyCallback.Sev2);
      $(document).bind('keydown', '3', Snorby.hotKeyCallback.Sev3);

      $(document).bind('keydown', 'shift+right', Snorby.hotKeyCallback.shiftPlusRight);
      $(document).bind('keydown', 'right', Snorby.hotKeyCallback.right);
      $(document).bind('keydown', 'shift+left', Snorby.hotKeyCallback.shiftPlusLeft);
      $(document).bind('keydown', 'left', Snorby.hotKeyCallback.left);
    } else {

			$(document).unbind('keydown', Snorby.hotKeyCallback.Sev1);
      $(document).unbind('keydown', Snorby.hotKeyCallback.Sev2);
      $(document).unbind('keydown', Snorby.hotKeyCallback.Sev3);

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
				$.post(baseuri + '/users/toggle_settings', { user_id: user_id, user: { enabled: true }, authenticity_token: csrf});
			} else {
				$.post(baseuri + '/users/toggle_settings', { user_id: user_id, user: { enabled: false }, authenticity_token: csrf});
			};
		});

		$('#users input#admin').live('click', function(e) {
			var user_id = $(this).parent('td').attr('data-user');
			if ($(this).attr('checked')) {
				$.post(baseuri + '/users/toggle_settings', { user_id: user_id, user: { admin: true }, authenticity_token: csrf});
			} else {
				$.post(baseuri + '/users/toggle_settings', { user_id: user_id, user: { admin: false }, authenticity_token: csrf});
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

    update_notifications: function(data) {
      var self = this;
      var template = '<div id="update-notification">' +
        '<span>' +
        '<div class="message-update-notification">' +
        'A new version of Snorby is now avaliable. ' +
        '</div>' +
        'Version {{version}} - ' +
        '' +
        '<a href="{{download}}" target="_blank">Download</a>  - ' +
        '<a href="{{changeLog}}" target="_blank">Change Log</a>' +
        '' +
        '<div class="close-update-notification">x</div>' +
        '</span>' +
        '</div>';

      $('div.close-update-notification').live('click', function(e) {
        e.preventDefault();
        $.cookie('snorby-ignore-update', 1, { expires: 20 });
        $('div#update-notification').remove();
      });

      return Snorby.templates.render(template, data);
    },

    searchLoading: function() {
      var self = this;
      var template = '<div class="search-loading" />';
      return template;
    },

    signatureTable: function() {
      var self = this;
      var template = '<div id="signatures-input-search" class="grid_12 page boxit" style="display: block;">' +
        '<table class="default" border="0" cellspacing="0" cellpadding="0">' +
        '<tbody><tr><th style="width:30px">Sev.</th><th>Signature Name</th><th>Event Count</th><th></th></tr></tbody>' +
        '<tbody class="signatures content">' +
        '</tbody>' +
        '</table>' +
        '</div>';

      return template;
    },

    signatures: function(data) {
      var self = this;
      var event_count = data.total;

      var template = '{{#each signatures}}' +
        '<tr>' +
        '<td class="first">' +
        '<div class="severity small">' +
        '<span class="severity sev{{sig_priority}}">' +
        '{{sig_priority}}' +
        '</span>' +
        '</div>' +
        '</td>' +
        '<td class="" title="{{sig_name}}">' +
        '{{{truncate this.sig_name 60}}}' +
        '</td>' +
        '<td class="chart-large add_tipsy" original-title="{{events_count}} of {{../total}} events">' +
        '<div class="progress-container-large">' +
        '<div style="width: {{{percentage ../total}}}%">' +
        '<span>{{{percentage ../total}}}%</span>' +
        '</div>' +
        '</div>' +
        '</td>' +
        '<td class="last" style="width:45px;padding-right:6px;padding-left:0px;">' +
        '<a href="results?match_all=true&search%5Bsignature%5D%5Bcolumn%5D=signature&search%5Bsignature%5D%5Boperator%5D=is&search%5Bsignature%5D%5Bvalue%5D={{sig_id}}&title={{sig_name}}">View</a>' +
        '</td>' +
        '</tr>{{/each}}';
      return Snorby.templates.render(template, data);
    }

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
				window.location = baseuri + '/';
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

        var sessions = false;
        if ($('#events').data('action') === "sessions") {
          var sessions = true;
          if ($('div#sessions-event-count-selected').length == 0) {
           $('#content').append('<div id="sessions-event-count-selected" data-count="0" />');
          };

          var current_count = parseInt($('div#sessions-event-count-selected').data('count'));
        };

        var checked = $(this).is(':checked');

				if (checked) {

					selected_events.push(event_id);
					$('input#selected_events[type="hidden"]').val(selected_events);

				} else {

					var removeItem = event_id;
					selected_events = jQuery.grep(selected_events, function(value) {
						return value != removeItem;
					});

					$('input#selected_events[type="hidden"]').val(selected_events);
				};

        if (sessions) {
          var session_count = parseInt($(this).parents('li.event').find('div.session-count').data('sessions'));

          if (session_count) {
            var value = 0;

            if (checked) {
              value = current_count + session_count;
            } else {
              value = current_count - session_count;
            };

            $('div#sessions-event-count-selected').data('count', value);
          };
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

        var notes = $(this).parents('.pager').hasClass('notes-pager');

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

          if ($('div#search-params').length > 0) {

            var search_data = JSON.parse($('div#search-params').text());

            if (search_data) {
              $.ajax({
                url: $(self).find('a').attr('href'),
                global: false,
                dataType: 'script',
                data: {
                  match_all: search_data.match_all,
                  search: search_data.search,
                  authenticity_token: csrf
                },
                cache: false,
                type: 'POST',
                success: function(data) {
                  $('div.content').fadeTo(500, 1);
                  Snorby.helpers.remove_click_events(false);
                  Snorby.helpers.recheck_selected_events();

                  if (!notes) {
                    if (history && history.pushState) {
                      history.pushState(null, document.title, $(self).find('a').attr('href'));
                    };
                    $.scrollTo('#header', 500);
                  };
                }
              });
            };

          } else {
            $.getScript($(self).find('a').attr('href'), function() {
              $('div.content').fadeTo(500, 1);
              Snorby.helpers.remove_click_events(false);
              Snorby.helpers.recheck_selected_events();

              if (!notes) {
                if (history && history.pushState) {
                  history.pushState(null, document.title, $(self).find('a').attr('href'));
                };
                $.scrollTo('#header', 500);
              };

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
    },

    Sev1: function() {
      $('span.sev1').parents('div.row').find('input#event-selector').each(function() {
        var $checkbox = $(this);
        $checkbox.attr('checked', !$checkbox.attr('checked'));
        $checkbox.trigger('change');
      });
    },

    Sev2: function() {
      $('span.sev2').parents('div.row').find('input#event-selector').each(function() {
        var $checkbox = $(this);
        $checkbox.attr('checked', !$checkbox.attr('checked'));
        $checkbox.trigger('change');
      });
    },

    Sev3: function() {
      $('span.sev3').parents('div.row').find('input#event-selector').each(function() {
        var $checkbox = $(this);
        $checkbox.attr('checked', !$checkbox.attr('checked'));
        $checkbox.trigger('change');
      });
    }

  },

	hotkeys: function(){
    var self = this;

		$(document).bind('keydown', 'ctrl+shift+h', function() {
      // ...
			return false;
		});

		$(document).bind('keydown', 'ctrl+3', function() {
			window.location = baseuri + '/jobs';
			return false;
		});

		$(document).bind('keydown', 'ctrl+2', function() {
			window.location = baseuri + '/events';
			return false;
		});

		$(document).bind('keydown', 'ctrl+1', function() {
			window.location = baseuri + '/events/queue';
			return false;
		});

		$(document).bind('keydown', 'ctrl+shift+s', function() {
			window.location = baseuri + '/search';
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

			$(document).bind('keydown', 'ctrl+shift+1', Snorby.hotKeyCallback.Sev1);
      $(document).bind('keydown', 'ctrl+shift+2', Snorby.hotKeyCallback.Sev2);
      $(document).bind('keydown', 'ctrl+shift+3', Snorby.hotKeyCallback.Sev3);

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

			if ($('input#_settings_packet_capture').is(':checked')) {
				$('div.pc-settings').show();
				$('p.pc-settings input[type="text"], p.pc-settings select').addClass('required');
			} else {
				$('div.pc-settings').hide();
				$('p.pc-settings input[type="text"], p.pc-settings select').removeClass('required');
			};

			if ($('input#_settings_packet_capture_auto_auth').is(':checked')) {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', null);
			} else {
        $('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', 'disabled');
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').removeClass('required');
			};

			var packet_capture_plugin = $('select#_settings_packet_capture_type').attr('packet_capture_plugin');

			$('select#_settings_packet_capture_type option[value="'+packet_capture_plugin+'"]').attr('selected', 'selected');

      if ($('input#_settings_autodrop').is(':checked')) {
        $('select#_settings_autodrop_count').attr('disabled', null);
      } else {
        $('select#_settings_autodrop_count').attr('disabled', 'disabled');
      };

      var autodrop_count = $('select#_settings_autodrop_count').attr('autodrop_count');
			$('select#_settings_autodrop_count option[value="'+autodrop_count+'"]').attr('selected', 'selected');
		};

		$('input#_settings_packet_capture').live('click', function() {
			if ($('input#_settings_packet_capture').is(':checked')) {
				$('div.pc-settings').show();
				$('p.pc-settings input[type="text"], p.pc-settings select').addClass('required');
			} else {
				$('div.pc-settings').hide();
				$('p.pc-settings input[type="text"], p.pc-settings select').removeClass('required');
			};
		});

    $('input#_settings_autodrop').live('click', function() {

      if ($(this).is(':checked')) {
        $('select#_settings_autodrop_count').attr('disabled', null);
      } else {
        $('select#_settings_autodrop_count').attr('disabled', 'disabled');
      };

    });

		$('input#_settings_packet_capture_auto_auth').live('click', function() {
			if ($('input#_settings_packet_capture_auto_auth').is(':checked')) {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').addClass('required');
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', null);
			} else {
				$('input#_settings_packet_capture_user, input#_settings_packet_capture_password').removeClass('required');
        $('input#_settings_packet_capture_user, input#_settings_packet_capture_password').attr('disabled', 'disabled');
			};
		});

	},

	jobs: function() {

		$('a.view_job_handler, a.view_job_last_error').limp({
        cache: true,
        round: 0,
        loading: true,
        animation: 'pop',
        enableEscapeButton: true,
        shadow: '0 1px 30px rgba(0,0,0,0.6)',
        style: {
          background: 'rgba(36,36,36,0.9)',
          border: '1px solid rgba(0,0,0,0.9)',
          padding: '5px',
          width: '700px'
        },
        inside: {
          border: '1px solid rgba(0,0,0,0.9)',
          padding: 0
        },
        overlay: {
          background: '#000',
          opacity: 0.6
        },
        onOpen: function() {
          Snorby.eventCloseHotkeys(false);
          $('dl#event-sub-menu').hide();
        },
        afterOpen: function(limp, html) {

          html.find('#snorbybox-content .add_chosen').chosen({
            allow_single_deselect: true
          });
        },
        onClose: function() {
          Snorby.eventCloseHotkeys(true);
        }
      });

	}

};

jQuery(document).ready(function($) {

  Handlebars.registerHelper('geoip', function(ip) {
    if (ip) {
      var name = ip.country_name;
      var code = ip.country_code2;
      if (name === "--") { name = 'N/A' };

      return '<div class="click ' +
      'country_flag add_tipsy_html" title="&lt;img class=&quot;flag&quot; ' +
      'src=&quot;/images/flags/'+code.toLowerCase()+'.png&quot;&gt; ' + name + '">' + code + '</div>';
    } else {
      return null;
    };
  });

  Handlebars.registerHelper('format_time', function(time) {
    // 2012-09-22 19:25:13 UTC
    return moment(time).utc().add('seconds', Snorby.current_user.timezone_offset).format('MMMM DD, YYYY HH:mm:ss'); //.fromNow();
  });

  Handlebars.registerHelper('short_format_time', function(time) {
    // 2012-09-22 19:25:13 UTC
    return moment(time).utc().add('seconds', Snorby.current_user.timezone_offset).format('MM/DD/YY HH:mm:ss'); //.fromNow();
  });

  Handlebars.registerHelper('format_unix_js', function(time) {
    // 2012-09-22 19:25:13 UTC
    time = Math.floor(time / 1000);
    return moment.unix(time).utc().add('seconds', Snorby.current_user.timezone_offset).format('MM/DD/YY hh:mm:ss A ') + Snorby.current_user.timezone; //.fromNow();
  });

  Handlebars.registerHelper('truncate', function(data, length) {
     if (data.length > length) {
       return data.substring(0,length) + "...";
     } else {
      return data;
     };
  });

  Handlebars.registerHelper('build_asset_name_agent_list', function() {
    var buffer = "";

    for (var i = 0; i < this.agents.length; i += 1) {
      var a = this.agents[i];

      if (a.name === "Click To Change Me") {
        var name = a.hostname;
      } else {
        var name = a.name;
      };

      if (this.hasOwnProperty('agent_ids')) {
        if ($.isArray(this.agent_ids)) {
          if ($.inArray(a.sid, this.agent_ids) >= 0) {
            buffer += "<option selected value='"+a.sid+"'>" + name + "</option>";
          } else {
            buffer += "<option value='"+a.sid+"'>" + name + "</option>";
          };
        } else {
          buffer += "<option value='"+a.sid+"'>" + name + "</option>";
        };
      } else {
        buffer += "<option value='"+a.sid+"'>" + name + "</option>";
      };

    }

    return buffer;
  });


  Handlebars.registerHelper('sensor_name', function() {
    if (this.name === "Click To Change Me") {
      return this.hostname;
    } else {
      return this.name;
    };
  });



  Handlebars.registerHelper('percentage', function(total) {
    var calc = ((parseFloat(this.events_count) / parseFloat(total)) * 100);
    return calc.toFixed(2);
  });

  $('#login form#new_user').submit(function(event) {
    event.preventDefault();
    var self = $('#login');
    var that = this;

    if ($('#password').length > 0) {
      that.submit();
    } else {
      var password_value = $('input#user_password', that).attr('value');
    };

    var email_value = $('input#user_email', that).attr('value');

    if (password_value && (password_value.length > 1)) {
      if (email_value.length > 5) {
        $('div.auth-loading').fadeIn('slow');
        $.post(that.action, $(that).serialize(), function(data) {
          if (data.success) {
            $('div.auth-loading span').fadeOut('slow', function(){
              $(this).html('Authentication Successful, Please Wait...');
              $(this).fadeIn('slow');
            });
            $.get(data.redirect, function(data) {
              self.fadeOut('slow', function() {
                document.open();
                document.write(data);
                document.close();
                history.pushState(null, 'Snorby - Dashboard', baseuri + '/');
              });
            });

          } else {
            flash_message.push({
              type: 'error',
              message: "Error, Authentication Failed!"
            });
            flash();
            $('div.auth-loading').fadeOut();
          };
        });

      };
    };
  });

  //remove the title div from login pages
  $('#login #title').remove();

  $('img.avatar, img.avatar-small, div.note-avatar-holder img').error(function(event) {
    $(this).attr("src", baseuri + "/images/default_avatar.png");
  })

  $('#login button.forgot-my-password').live('click', function(event) {
    event.preventDefault();
    $.get(baseuri + '/users/password/new', function(data) {
      var content = $(data).find('#content').html();
      $('#login').html(content);
      history.pushState(null, 'Snorby - Password Reset', baseuri + '/users/password/new');
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

  $('td.search-by-signature').live('click', function(event) {
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

  $('.add_chosen').chosen({
    allow_single_deselect: true
  });

  $('ul.table div.content li.event').live('hover', function() {
    $('ul.table div.content li.event').removeClass('currently-over');
    $(this).toggleClass('currently-over');
  }, function() {
    $(this).toggleClass('currently-over');
  });

  var signature_input_search = null;
  var signature_input_search_last = null;
  var signature_input_search_timeout = null;

  $('input#signature-search').live('keyup', function() {
    var value = $(this).val().replace(/^\s+|\s+$/g, '');

    if (value.length >= 3) {

      if (value !== signature_input_search_last) {
        if (signature_input_search) { signature_input_search.abort() };

        signature_input_search_last = value;

        if ($('div.search-loading').length == 0) {
          $('div#title').append(Snorby.templates.searchLoading());
        };

        signature_input_search = $.ajax({
          url: baseuri + '/signatures/search',
          global: false,
          data: { q: value, authenticity_token: csrf },
          type: "POST",
          dataType: "json",
          cache: false,
          success: function(data) {
            signature_input_search = null;
            signature_input_search_last = value;

            $('div#signatures').hide();
            $('div.search-loading').remove();

            if ($('div#signatures-input-search').length == 0) {
              $('div#content').append(Snorby.templates.signatureTable());
            };

            $("div#signatures-input-search tbody.signatures").html(Snorby.templates.signatures(data));
          }
        });
      };

    } else {
      $('div#signatures').show();
      $("div#signatures-input-search").remove();
      $('div.search-loading').remove();
      signature_input_search_last = null;
      if (signature_input_search) { signature_input_search.abort() };
    };
  });

  var cache_reload_count = 0;
  function currently_caching() {
    $.ajax({
      url: baseuri + '/cache/status',
      global: false,
      dataType: 'json',
      cache: false,
      type: 'GET',
      success: function(data) {
        if (data.caching) {
          setTimeout(function() {
            cache_reload_count = 0;
            currently_caching();
          }, 2000);
        } else {
          if (cache_reload_count == 3) {
            cache_reload_count = 0;
            location.reload();
          } else {
            cache_reload_count++;
            currently_caching();
          };
        };
      }
    });
  };

  $('dd a.force-cache-update').live('click', function(e) {
    e.preventDefault();
    $('li.last-cache-time')
    .html("<i>Currently Caching <img src='../images/icons/pager.gif' width='16' height='11' /></i>");

    $.getJSON(this.href, function(data) {
      setTimeout(currently_caching, 6000);
    });
  });

  $('.snorby-content-restore').live('click', function(e) {
    e.preventDefault();

    if ($('.tmp-content-data').length > 0) {

      $('.tmp-content-data, #footer').stop().delay(100).animate({
        opacity: 0
      }, 600, function() {
        $('.tmp-content-data').hide();

        $('.original-content-data, #footer').stop().delay(100).show().animate({
          opacity: 1
        }, 600);
      });
    };

  });

  $('.snorby-content-replace').live('click', function(e) {
    e.preventDefault();

    if ($('.tmp-content-data').length > 0) {

      $('.original-content-data, #footer').stop().delay(100).animate({
        opacity: 0
      }, 600, function() {
        $('.original-content-data').hide();
        $('.tmp-content-data, #footer').stop().delay(100).show().animate({
          opacity: 1
        }, 600);
      });

    } else {

      $('#content').addClass('original-content-data');

      var item = '<li><a href="#" class="snorby-content-restore"><img' +
        ' alt="Restart" src="' + baseuri + '/images/icons/restart.png">Go Back</a></li>';
      var menu = '<ul class="" id="title-menu-holder"><ul id="title-menu">' +
        '<li>&nbsp;</li>'+item+'<li>&nbsp;</li></ul></ul>';

      $.ajax({
        url: 'saved/searches',
        global: false,
        dataType: 'html',
        cache: false,
        type: 'GET',
        success: function(data) {

          var $content = $(data).find('#content')
          .addClass('tmp-content-data').hide().css({
            opacity: 0
          });

          var titleMenu = $content.find('#title-menu');

          if (titleMenu.length > 0) {
            titleMenu.find('li:last-child').before(item);
          } else {
           $content.find('#title').append(menu);
          };

          $('.original-content-data, #footer').stop().delay(100).animate({
            opacity: 0
          }, 600, function() {
            $('.original-content-data').before($content);
            $('.original-content-data').hide();
            $('.tmp-content-data, #footer').stop().delay(100).show().animate({
              opacity: 1
            }, 600);
          });
        }
      });
    };

  });

  $('body').on('click', 'button.new-saved-search-record', function(e) {
    e.preventDefault();
    var dd = false;

    if (typeof rule !== "undefined") {
      var dd = rule.pack();
    } else {
      var json = $('div#search-params').text();

      if (json) {
        try {
          var tmp = JSON.parse(json)
          var dd = {
            match_all: tmp.match_all,
            search: tmp.search
          };
        } catch(e) {
          var dd = false;
        }
      };
    };

    if (dd) {
      $('#snorby-box #form-actions button.success').attr('disabled', true);
      $('#snorby-box #form-actions button.success span').text('Please Wait...');

      var title = $('input#saved_search_title').val();
      var search_public = $('input#saved_search_public').is(":checked");

     $.ajax({
        url: baseuri + '/saved_searches/create',
        global: false,
        dataType: 'json',
        cache: false,
        type: 'POST',
        data: {
          "authenticity_token": csrf,
          "search": {
            "title": title,
            "public": search_public,
            "search": dd
          }
        },
        success: function(data) {

          if (data.error) {
            flash_message.push({type: 'error', message: "Error: This search may already exists."});flash();
          } else {
            flash_message.push({type: 'success', message: "Your search was saved successfully"});flash();
          };

          $(document).trigger('limp.close');
        },
        error: function(data) {
         flash_message.push({type: 'error', message: "Error: This search may already exists."});flash();
         $(document).trigger('limp.close');
        }
     });

    } else {
      flash_message.push({type: 'error', message: "An Unknown Error Has Occurred"});flash();
      $(document).trigger('limp.close');
    };
  });

  $('div.results a.table-sort-link').live('click', function(e) {
    e.preventDefault();

    if ($('div#search-params').length > 0) {

      var search_data = JSON.parse($('div#search-params').text());

      var direction = $(this).data('direction');
      var sort = $(this).data('sort');
      var page = $(this).data('page');

      var title = $(this).data('title');
      var search_id = $(this).data('search-id');

      var url = baseuri + "/results?sort=" + sort +
        "&direction="+direction+"&page=" + page;

      var params = {
        match_all: search_data.match_all,
        search: search_data.search,
        authenticity_token: csrf
      };

      if (title) {
        params.title = title;
      };

      if (search_id) {
        params.search_id = "" + search_id + "";
      };

      if (search_data) {
        post_to_url(url, params);
      };

    };

    return false;
  });

  // Disable clicking on deleting rows
  $('tr.deleted *').live('click', function(e){
    $('.edit-sensor-name').unbind('click');
    e.preventDefault();
  })

  $('#is-asset-name-global').live('change', function(e) {
    var value = $(this).is(':checked');
    if (value) {
      $('#edit-asset-name-agent-select').attr('disabled', true);
      $('.add_chosen').trigger("liszt:updated");
    } else {
      $('#edit-asset-name-agent-select').attr('disabled', false);
      $('.add_chosen').trigger("liszt:updated");
    };
  });

  $('.edit-asset-name').live('click', function(e) {
    e.preventDefault();
    var self = $(this);

    if (Snorby.getSensorList) {
      Snorby.getSensorList.abort();
    };

    $('.loading-bar').slideDown('fast');

    Snorby.getSensorList = $.ajax({
      url: baseuri + "/sensors/agent_list.json",
      type: "GET",
      dataType: "json",
      success: function(data) {

        $('.loading-bar').slideUp('fast');

        var params = {
          ip_address: self.attr('data-ip_address'),
          agent_id: self.attr('data-agent_id'),
          asset_name: self.attr('data-asset_name'),
          asset_id: self.attr('data-asset_id'),
          global: (self.attr('data-asset_global') === "true" ? true : false),
          agents: data
        };

        params.agent_ids = [];
        if (self.attr('data-asset_agent_ids')) {
          var ids = self.attr('data-asset_agent_ids').split(',');
           for (var i = 0; i < ids.length; i += 1) {
             params.agent_ids.push(parseInt(ids[i]));
           }
        }
        var box = Snorby.box('edit-asset-name', params);
        box.open();
      },
      error: function(a,b,c) {
        $('.loading-bar').slideUp('fast');
        flash_message.push({
          type: 'error',
          message: "Unable to edit asset name for address."
        });
        flash();
      }
    });

  });

  $('a.destroy-asset-name').live('click', function(e) {
    e.preventDefault();
    var id = $(this).attr('data-asset_id');

    var box = Snorby.box('confirm', {
      title: "Remove Asset Name",
      message: "Are you sure you want to remove this asset name? This action cannot be undone.",
      button: {
        title: "Yes",
        type: "default success"
      },
      icon: "warning"
    }, {
      onAction: function() {
        $('.loading-bar').slideDown('fast');
        $('.limp-action').attr('disabled', true).find('span').text('Loading...');
        $.ajax({
          url: baseuri + '/asset_names/' + id + '/remove',
          type: 'delete',
          data: {
            csrf: csrf
          },
          dataType: "json",
          success: function(data) {
            $('.loading-bar').slideUp('fast');
            $.limpClose();
            $('tr[data-asset-id="'+id+'"]').remove();
          },
          error: function(a,b,c) {
            $('.loading-bar').slideUp('fast');
            $.limpClose();
          }
        });
      }
    });

    box.open();
  });

});



