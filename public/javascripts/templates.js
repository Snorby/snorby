(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['confirm'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  
  return "\n      ";}

function program3(depth0,data) {
  
  
  return "\n      <button class='warning cancel-snorbybox default' onClick='$.limpClose()'><span>Cancel</span></button>\n      ";}

  buffer += "<div class=\"snorby-box\" id=\"snorby-box\">\n\n  <div id=\"box-title\">\n    ";
  foundHelper = helpers.title;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.title; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\n    <div class=\"more\">\n    </div>\n  </div>\n  <div id=\"box-content-small\">\n\n    <div id=\"snorbybox-content\" class=\"\">\n      <div class='snorbybox-content-message'>\n      ";
  foundHelper = helpers.message;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.message; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n      </div>\n    </div>\n\n    <div id=\"box-footer\">\n      <div id=\"form-actions\">\n\n      <button class='button ";
  stack1 = depth0.button;
  stack1 = stack1 == null || stack1 === false ? stack1 : stack1.type;
  stack1 = typeof stack1 === functionType ? stack1() : stack1;
  buffer += escapeExpression(stack1) + " limp-action'><span>";
  stack1 = depth0.button;
  stack1 = stack1 == null || stack1 === false ? stack1 : stack1.title;
  stack1 = typeof stack1 === functionType ? stack1() : stack1;
  buffer += escapeExpression(stack1) + "</span></button>\n\n      ";
  stack1 = depth0.ignore_cancel;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n      </div>\n\n    </div>\n\n  </div>\n</div>\n";
  return buffer;});
templates['edit-asset-name'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1, foundHelper;
  buffer += "value=\"";
  foundHelper = helpers.asset_name;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.asset_name; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\"";
  return buffer;}

function program3(depth0,data) {
  
  
  return "checked";}

function program5(depth0,data) {
  
  
  return "disabled";}

  buffer += "<div class=\"snorby-box\" id=\"snorby-box\">\n\n  <div id=\"box-title\">\n    Edit Asset Name For ";
  foundHelper = helpers.ip_address;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.ip_address; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\n    <div class=\"more\"></div>\n  </div>\n  <div id=\"box-content-small\">\n\n    <div id=\"snorbybox-content\" class=\"\">\n        <form class=\"update-asset-name-form\" action=\"#\">\n          <div class=\"grid_5\">\n            \n            <input type=\"hidden\" name=\"ip_address\" value=\"";
  foundHelper = helpers.ip_address;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.ip_address; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\" />\n            <input type=\"hidden\" name=\"id\" value=\"";
  foundHelper = helpers.asset_id;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.asset_id; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\" />\n\n            <p>\n              <input id=\"edit-asset-name-title\" ";
  stack1 = depth0.asset_name;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(1, program1, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " name=\"name\" type=\"text\" style='width:339px;' placeholder=\"Enter Asset Name\" />\n            </p>\n\n            <div class=\"clear\"></div>\n\n            <p>\n              <input type=\"checkbox\" id='is-asset-name-global' name=\"global\" ";
  stack1 = depth0.global;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(3, program3, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " />\n              <label>Enable Globally</label> <em>(Enable this rule for all agents)</em><br />\n            </p>\n\n            <div class=\"clear\"></div>\n\n            <div id='snorbybox-form-full'>\n              <select ";
  stack1 = depth0.global;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(5, program5, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " style=\"width:350px;margin-bottom:5px;\" name=\"agents\" id=\"edit-asset-name-agent-select\" class='add_chosen' \"data-placeholder\"=\"Select individual agents\" multiple name=\"\">\n                ";
  foundHelper = helpers.build_asset_name_agent_list;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.build_asset_name_agent_list; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n              </select>\n              <br />\n            </div>\n          \n          </div>\n\n          <div class=\"grid_5\" style='width:287px;'>\n            <div class=\"note no-click\">\n              <div class=\"message\">\n                <strong>Global</strong> This asset name will be used for all agents that match this address.<br />\n              </div>\n            </div>\n          </div>\n\n          <div class=\"clear\"></div>\n\n          <br />\n\n          <div id=\"box-footer\">\n            <div id=\"form-actions\">\n              <button class='update-asset-name-submit-button button success default' onclick=\"Snorby.submitAssetName(); return false;\">\n                <span>Update</span>\n              </button>\n              <button class='warning cancel-snorbybox default' onClick='$.limpClose()'><span>Cancel</span></button>\n            </div>\n          </div>\n\n        </form>\n    </div>\n\n\n  </div>\n</div>\n";
  return buffer;});
templates['search-rule'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  


  return "<div class=\"search-content-box\">\n  <div class=\"inside\">\n\n    <div class=\"search-content-enable search-content-box-item\">\n      <input name=\"enable-current-search-content\" checked='checked' type=\"checkbox\" />\n    </div>\n\n    <div class=\"column-select search-content-box-item\">\n      <select class='add_chosen'>\n        <option value='any'>Any</option>\n        <option value='all'>All</option>\n      </select> \n    </div>\n\n    <div class=\"operator-select search-content-box-item\">\n      <select class='add_chosen'>\n        <option value='is'>is</option>\n        <option value='is_not'>is not</option>\n      </select>      \n    </div>\n\n    <div class=\"value search-content-box-item\">\n      <input class='search-content-value' placeholder=\"Enter search value\" name=\"\" type=\"text\" /> \n    </div>\n\n    <div class=\"search-button-box-holder\">\n      <div class=\"search-button-box-inside\">\n        <div class=\"search-button-box\">\n\n          <div title='Remove search rule' class=\"search-content-remove search-content-box-item\">\n            <img src=\"/images/icons/minus.png\" alt=\"\" />\n          </div>\n\n          <div title='Add new search rule' class=\"search-content-add search-content-box-item\">\n            <img src=\"/images/icons/add.png\" alt=\"\" />\n          </div>\n\n        </div>\n      </div>\n    </div>\n\n  </div>\n</div>\n";});
templates['search'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div id=\"search\" class=\"boxit page grid_12\">\n\n  <div class=\"search-match-box\" style=\"display:;\">\n    Match \n    <select class=\"global-match-setting\">\n      <option value=\"any\">Any</option>\n      <option value=\"all\" selected=\"selected\">All</option>\n    </select> \n    of the following rules: \n  </div>\n\n  <div class=\"other-search-options\" style=\"display:none;\">\n    <input name=\"limit-all-search-rules\" type=\"checkbox\"> \n    Limit to\n    <input class=\"limit-search-results-count\" name=\"limit-search-results-to\" type=\"text\" value=\"10000\"> \n    ordered by\n    <select><option value=\"any\">Event Timestamp</option><option value=\"all\">All</option></select>\n    <br>\n    <input name=\"ignore-classified-events\" type=\"checkbox\"> Ignore all classified events.\n  </div>\n\n  <div class=\"rules\"></div>\n\n  <div id=\"form-actions\">\n    <button class=\"";
  foundHelper = helpers.cssClass;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.cssClass; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + " success default\"><span>";
  foundHelper = helpers.buttonTitle;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.buttonTitle; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "</span></button>\n  </div>\n</div>\n";
  return buffer;});
templates['select'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, functionType="function", escapeExpression=this.escapeExpression, self=this, blockHelperMissing=helpers.blockHelperMissing;

function program1(depth0,data) {
  
  
  return "multiple";}

function program3(depth0,data) {
  
  var buffer = "", stack1, foundHelper;
  buffer += "style=\"width:";
  foundHelper = helpers.width;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.width; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + ";\"";
  return buffer;}

function program5(depth0,data) {
  
  var buffer = "", stack1, foundHelper;
  buffer += "data-placeholder=\"";
  foundHelper = helpers.placeholder;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.placeholder; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\"";
  return buffer;}

function program7(depth0,data) {
  
  
  return "<option value=\"\"></option>";}

function program9(depth0,data) {
  
  var buffer = "", stack1, foundHelper;
  buffer += "\n    <option value=\"";
  foundHelper = helpers.id;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.id; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\">";
  foundHelper = helpers.value;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.value; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "</option>\n  ";
  return buffer;}

  buffer += "<select ";
  stack1 = depth0.multiple;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(1, program1, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " ";
  stack1 = depth0.width;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(3, program3, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " \n  class=\"add_chosen\" \n  ";
  stack1 = depth0.placeholder;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(5, program5, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n  name=\"";
  foundHelper = helpers.name;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\">\n\n  ";
  stack1 = depth0.placeholder;
  stack1 = helpers['if'].call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(7, program7, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n  ";
  stack1 = depth0.data;
  stack1 = stack1 == null || stack1 === false ? stack1 : stack1.value;
  stack1 = typeof stack1 === functionType ? stack1() : stack1;
  stack1 = stack1 = blockHelperMissing.call(depth0, stack1, {hash:{},inverse:self.noop,fn:self.program(9, program9, data)});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</select>\n\n\n";
  return buffer;});
})();