# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.


require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)
Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

Given /^(?:|I )az? (.+ (?:kezdő)?oldalra) megyek$/ do |page_name|
  visit path_to(page_name)
end

Given /várok (\d+) másodpercet/ do |seconds|
  sleep seconds.to_i
end

When /leokézom a js popupot a következő teszt lépésnél/ do 
  page.execute_script("window.alert = function(msg) { return true; }") 
  page.execute_script("window.confirm = function(msg) { return true; }") 
end

When /^(?:#{capture_model} )?az? "([^\"]*)" gombra kattint(ok|unk)?(?: within "([^\"]*)")?$/ do |name, button, anonym, selector|
  session = anonym == "unk" ? page : get_session(model(name || "én"))
  with_scope(selector) do
    session.click_button(button)
  end
end

Then /#{capture_model} egyedi státusz ikonja (láthat(?:ó|atlan))ra van állítva/ do |name, visibility|
  page.evaluate_script("$('#contact_id_#{model(name).id} .status_for_contact_icon').is('#{visibility == 'látható' ? ':not(.invisible).visible' : ':not(.visible).invisible'}')").should be_true
end

# akkor használatos ha nincs id vagy szöveg a linkhez
When /^(?:#{capture_model} )?az? "([^\"]*)" elemre kattint(?:ok)?$/ do |name, selector|
  get_session(model(name || "én")).execute_script("$('#{selector}').click()")
end

# akkor használatos ha van id vagy szöveg a linkhez
When /^(?:#{capture_model} )?az? "([^\"]*)" linkre kattint(ok|unk)?(?: within "([^\"]*)")?$/ do |name, link, anonym, selector|
  session = anonym == "unk" ? page : get_session(model(name || "én"))
  with_scope(selector) do
    session.click_link(link)
  end
end

When /^(?:|I )kitöltöm az? "([^\"]*)" mezőt a következővel "([^\"]*)"(?: within "([^\"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
When /^(?:|I )fill in the following(?: within "([^\"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}

      W
    end
  end
end

When /^(?:|I )az? "([^\"]*)"-t kiválasztom az? "([^\"]*)" elemből(?: within "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, :from => field)
  end
end

When /^(?:|I )az? "([^\"]*)"-t becsekkolom(?: within "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    check(field)
  end
end

When /^(?:|I )az? "([^\"]*)"-t kicsekkolom(?: within "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end

When /^(?:|I )az? "([^\"]*)"-t bejelölöm(?: within "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

When /^(?:|I )kiválasztom az? "([^\"]*)" filet az? "([^\"]*)" elemben(?: within "([^\"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    attach_file(field, Rails.root + path)
  end
end

Then /látnom kell a feltöltött képet/ do
  text = Eye.first.orig.url
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Akkor /^az? "([^\"]*)" kép "([^\"]*)" attributum értéke "([^\"]*)" kell legyen$/ do |selector, attr, value|
  if page.respond_to? :should
    page.evaluate_script("String(testImage.#{attr})").should eql(value)
  else
    assert_equal page.evaluate_script("String(testImage.#{attr})"), value
  end
end

Akkor /^az? "([^\"]*)" kép "([^\"]*)" attributum értéke "([^\"]*)" és "([^\"]*)" között kell legyen$/ do |selector, attr, min, max|
  value = page.evaluate_script("String(testImage.#{attr})").to_i
  if page.respond_to? :should
    (min.to_i < value && value < max.to_i).should be_true
  else
    assert min.to_i < value && value < max.to_i 
  end
end

Akkor /^az? "([^\"]*)" elem "([^\"]*)" attributum értéke "([^\"]*)" kell legyen$/ do |selector, attr, value|
  elem_attribute_value = page.find(selector)[attr]
  if page.respond_to? :should
    elem_attribute_value.should eql(value)
  else
    assert_equal elem_attribute_value, value
  end
end

Then /(?:#{capture_model}-ként )?látn(om|unk) kell az? "([^\"]*)" elemet/ do |name, anonymus, selector|
  #page.find(selector)
  session = anonymus == "unk" ? page : get_session(model(name || "én"))
  wait_until do
    visible = session.evaluate_script("$('#{selector}').is(':visible')")
    if page.respond_to? :should
      visible.should be_true
    else
      assert visible
    end
  end
end

Then /látnom kell az? "([^\"]*)" üres elemet/ do |selector|
  page.find(selector, :visible=>false)
end

Then /nem szabad látn(?:om|unk) az? "([^\"]*)" elemet/ do |selector|
  wait_until do
    its_hidden = page.evaluate_script("$('#{selector}').is(':hidden');")
    its_not_in_dom = page.evaluate_script("$('#{selector}').length == 0;")
    if page.respond_to? :should
      (its_hidden || its_not_in_dom).should be_true
    else
      assert its_hidden || its_not_in_dom
    end
  end
end

Then /nem szabad látnom a kivágott képet/ do
  if page.respond_to? :should
    page.find('img#saved')['src'].should eql("/images/noeyes.jpg")
  else
    assert page.find('img#saved')['src'], "/images/noeyes.jpg"
  end
end

Then /látnom kell #{capture_model} kivágott képét/ do |eye|
  src = model!(eye).picture.url
  # NOTE: ez az érték változhat ha lassú a teszt
  sleep 10
  src_in_browser = page.evaluate_script("testImage.src")
  if page.respond_to? :should
    src_in_browser.should eql(src)
  else
    assert_equal src_in_browser, src
  end
end

Then /az? "([^\"]*)" custom constant értéke #{capture_value}/ do |const, value|
  case value
  when /^[+-]?[0-9_]+(\.\d+)?$/
    CustomConstant.const_set(const.to_sym, value.to_f)
  else
    CustomConstant.const_set(const.to_sym, eval(value))
  end
end

Then /^a (".*") json választ kell kapnom/ do |expected_json|
  require 'json'
  expected = JSON.pretty_generate(JSON.parse(expected_json))
  actual   = JSON.pretty_generate(JSON.parse(response.body))
  expected.should == actual
end

Then /^(?:|I )látnom kell az? "([^\"]*)" gombot(?: az? "([^\"]*)" elemben)?/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_button(text)
    else
      assert page.has_button?(text)
    end
  end
end

Then /^(?:|I )nem szabad látnom az? "([^\"]*)" gombot$/ do |text|
  if page.respond_to? :should
    page.should have_no_button(text)
  else
    assert page.have_no_button?(text)
  end
end

Then /az? "([^\"]*)" elem van a fokuszban/ do |selector|
  in_focus = page.evaluate_script("$('#{selector}')[0] === document.activeElement && ( $('#{selector}')[0].type || $('#{selector}')[0].href )")
  if page.respond_to? :should
    in_focus.should be_true
  else
    assert in_focus
  end
end

Then /^(?:#{capture_model}(?:-n[ae]k)? )?látn(om|ia|unk) kell az? "([^\"]*)" (?:szöveg|üzenet)et(?: az? "([^\"]*)" elemben)?$/ do |name, session, text, selector|
  session = session == "unk" ? page : get_session(model(name || "én"))
  with_scope(selector) do
    if session.respond_to? :should
      session.should have_content(text)
    else
      assert session.has_content?(text)
    end
  end
end

Then /^(?:#{capture_model} oldalán|az oldalon) található az? "([^\"]*)" (?:szöveg|üzenet|link) az? "([^\"]*)" elemben/ do |name, text, selector|
  wait_until do
    hidden = get_session(model(name || "én")).evaluate_script("$('#{selector}:contains(#{text})').is(':hidden')")
    if page.respond_to? :should
      hidden.should be_true
    else
      assert hidden
    end
  end
end

# javascriptes ellenőrzéshez
Then /^(?:#{capture_model}(?:-n[ae]k)? )?látn(om|ia|unk) kell az? "([^\"]*)" (?:szöveg|üzenet|link)et az? "([^\"]*)" elemben js/ do |name, anonym, text, selector|
  session = anonym == 'unk' ? page : get_session(model(name || "én"))
  wait_until do
    visible = session.evaluate_script("$('#{selector}:contains(#{text})').is(':visible')")
    if page.respond_to? :should
      visible.should be_true
    else
      assert visible
    end
  end
end

Then /^(?:#{capture_model}-ként )?nem szabad (látnom|látni) az? "([^\"]*)" szöveget az? "([^\"]*)" elemben/ do |name, session, text, selector|
  session = session == 'látnom' ? get_session(model(name || "én")) : page
  wait_until do
    its_hidden = session.evaluate_script("$('#{selector}:contains(#{text})').is(':hidden');")
    its_not_in_dom = session.evaluate_script("$('#{selector}:contains(#{text})').length == 0;")
    if page.respond_to? :should
      (its_hidden || its_not_in_dom).should be_true
    else
      assert its_hidden || its_not_in_dom
    end
  end
end

Then /(\d+) db "([^"]*)" elem található (?:#{capture_model} )?oldal[oá]n$/ do |count, selector, name|
  get_session(model(name || "én")).all(:css, selector).size.should == count.to_i
end

Then /^(?:#{capture_model} oldalán )?az? "([^"]*)" elem "([^"]*)" attributuma "([^"]*)" kell legyen$/ do |name, selector, attr, value|
  # NOTE: false a visible mert itt nem azt vizsgáljuk hogy látszik e hanem az attributumát
  elem_attr = get_session(model(name || "én")).find(:css, selector, :visible=>false)[attr.to_sym]
  if page.respond_to? :should
    elem_attr.should eql(value)
  else
    assert elem_attr, value
  end
end

Then /a feltöltött képek már fel vannak dolgozva/ do
  Eye.update_all(:prepared=>true)
end

Then /az aktivált képem "([^\"]*)"-ja "([^\"]*)"/ do |attr, value|
    eye_id = User.first.eye.id
    if page.respond_to? :should
      eye_id.should eql(value.to_i)
    else
      assert eye_id, value.to_i
    end
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should contain "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should not contain "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^\"]*)" checkbox(?: within "([^\"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should == 'checked'
    else
      assert_equal 'checked', field_checked
    end
  end
end

Then /^the "([^\"]*)" checkbox(?: within "([^\"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should_not
      field_checked.should_not == 'checked'
    else
      assert_not_equal 'checked', field_checked
    end
  end
end
 
Given /innentől kezdve az ifindeye facebook alkalmazást használom/ do
  Capybara.current_session.driver.browser.switch_to.frame('iframe_canvas')
end

Given /innentől kezdve a (?:facebookot|default frame-t) használom/ do
  Capybara.current_session.driver.browser.switch_to.default_content
end

Then /^(?:|I )az? (.+ ?oldal[oá]n) kell legyek$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')} 
  
  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^mutasd az oldalt$/ do
  save_and_open_page
end

Akkor /^letöltöm az irányítószám alapján a találatokat$/ do
  (6480..9999).each do |i|
    f = File.open("db/civil_#{i}.txt", 'w')
    When %Q{kitöltöm a "tbxZip" mezőt a következővel "#{i}"}
    And %q{a "Keresés" gombra kattintunk}
    begin 
#      Then %q{látnunk kell az "elem megjelenítve" szöveget}
      @klink = []
      @klinks = all(".OITH_DgBorder tr a")
      @klinks.size.times do |n|
        @klink[n] = @klinks[n].text
      end
      @klinks.size.times do |n|
        next if @klink[n].include?('"')
        a = @klink[n]
        And %Q{a "#{a}" linkre kattintunk}
        Then %q{látnunk kell az "részletes adatai" szöveget}
        @kdata = all(".OITH_InputUnit td")
        s = "#{i};"
        @kdata.size.times do |m|
          a = @kdata[m].try.text.gsub("\n", " ")
          s << "#{a}!;!"
        end
        f.puts(s)
        f.flush
        sleep 0.4
        And %Q{a "Vissza a találatokhoz" linkre kattintunk}
      end
      vanmeg = page.has_css?("a[name=linkNext]")
      if vanmeg
        linkNext = find("a[name=linkNext]")
        And %Q{a "#{linkNext.text}" linkre kattintunk}
      end
    end while vanmeg
    f.close
    And %Q{a "Vissza a kereséshez" linkre kattintunk}
  end
end

