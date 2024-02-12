prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run the script connected to SQL*Plus as the owner (parsing schema)
-- of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2022.10.07'
,p_release=>'22.2.0'
,p_default_workspace_id=>1860724163047204
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'APPWS'
);
end;
/
 
prompt APPLICATION 102 - plugin app official
--
-- Application Export:
--   Application:     102
--   Name:            plugin app official
--   Date and Time:   14:37 Monday February 12, 2024
--   Exported By:     ADMIN
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 15489522983001314
--   Manifest End
--   Version:         22.2.0
--   Instance ID:     860332959241800
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/pretius_drawing_plugin
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(15489522983001314)
,p_plugin_type=>'REGION TYPE'
,p_name=>'PRETIUS_DRAWING_PLUGIN'
,p_display_name=>'Pretius Drawing Plugin'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#map.js',
'#PLUGIN_FILES#control-functions.js',
'#PLUGIN_FILES#mobile-functionality.js'))
,p_css_file_urls=>'#PLUGIN_FILES#global.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/**',
' * Function: render_region',
' * Description: Renders the region for the drawing plugin.',
' * ',
' * @param p_region              IN apex_plugin.t_region - The region object.',
' * @param p_plugin              IN apex_plugin.t_plugin - The plugin object.',
' * @param p_is_printer_friendly IN BOOLEAN - Indicates if the rendering is for printer-friendly version.',
' * ',
' * @return apex_plugin.t_region_render_result - The result of the region rendering.',
' */',
'FUNCTION render_region(p_region              IN apex_plugin.t_region,',
'                       p_plugin              IN apex_plugin.t_plugin,',
'                       p_is_printer_friendly IN BOOLEAN)',
'  RETURN apex_plugin.t_region_render_result IS',
'  -- plugin attributes',
'  l_result   apex_plugin.t_region_render_result;',
'  l_attr_01  p_region.attribute_01%TYPE := p_region.attribute_01;',
'  l_editable p_region.attribute_02%TYPE := p_region.attribute_02;',
'  l_left_margin p_region.attribute_04%TYPE := p_region.attribute_04;',
'  l_top_margin  p_region.attribute_05%TYPE := p_region.attribute_05;',
'  -- other vars',
'  l_region_id       VARCHAR2(4000 char);',
'  l_ajax_identifier clob;',
'  v_data            apex_plugin_util.t_column_value_list;',
'  v_json            clob;',
'  v_json_enclave    clob;',
'  v_object_id       varchar2(4000 char);',
'  --',
'BEGIN',
'  -- Debug',
'  IF apex_application.g_debug THEN',
'    apex_plugin_util.debug_region(p_plugin => p_plugin,',
'                                  p_region => p_region);',
'  END IF;',
'  -- set vars',
'  l_region_id := nvl(apex_escape.html_attribute(p_region.static_id),''drawing-region'');',
'  l_ajax_identifier := apex_plugin.get_ajax_identifier;                                          ',
'  -- escape input',
'  l_attr_01 := apex_escape.html(l_attr_01);',
'  --',
'/*---------------------',
'    RENDER START',
'----------------------*/',
'  sys.htp.p(''<div id="drawing-plugin-''||l_region_id||''" data-ajax-identifier="''||l_ajax_identifier||''"'' ||',
'            '' class="drawing-plugin-body">'');',
'  --STYLE',
'  sys.htp.p(''<style>'');',
'  for component_rec in (select css from type_component)',
'    loop',
'      sys.htp.p(component_rec.css);',
'    end loop;',
'  sys.htp.p(''</style>'');',
'  --',
'  if l_editable = ''Y'' then ',
'    sys.htp.p(''<div class="grid-left">'');',
'  else ',
'    sys.htp.p(''<div class="grid-full-span">'');',
'  end if;',
'  if l_editable = ''Y'' then ',
'    sys.htp.p(''<div class="left-side-buttons">',
'      <div class="dropdown"  data-left-margin="''||l_left_margin||''" data-top-margin="''||l_top_margin||''">',
'        <button class="t-Button t-Button--primary t-Button--icon t-Button--iconLeft button-dropdown-map" ',
'          onclick="toggleMapSettings()" type="button" title="Map settings - on click open/hide options menu">',
'          <span class="t-Icon t-Icon--left fa fa-cog" aria-hidden="true"></span>',
'          <span class="t-Button-label">Map settings</span>',
'          <span class="t-Icon t-Icon--right fa fa-cog" aria-hidden="true"></span>',
'        </button>',
'        <div id="mapSettingsDropdown" class="dropdown-content">',
'        <div class="dropdown-inner">',
'          <label class="settings-label" for="background-color">Planner options</label>',
'          <div class="size-input">',
'            <label for="fname">Width:</label>',
'            <input type="text" id="winput" class="inputs" name="width" value="800">',
'          </div>',
'          <div class="size-input">',
'            <label for="fname">Height:</label>',
'            <input type="text" id="hinput" class="inputs" name="height" value="500">',
'          </div>',
'          <button class="t-Button t-Button--primary" type="button" onClick="showGrid();">Show Grid</button>',
'          <div style="margin: 10px 0px 0px 0px;">',
'            <div class="size-input">',
'              <label class="settings-label" for="background-color">Background options</label>',
'            </div>',
'            <div class="size-input">',
'              <label for="background-switch">Add background from image</label>',
'              <input onChange="setImage()" type="checkbox" id="background-switch" class="t-Switch-input">',
'            </div>',
'            <div class="size-input">',
'              <label for="image-path">Image path:</label>',
'              <input  onChange="setImage()" type="text" id="image-path" class="image-path-input" placeholder="Enter image path">',
'            </div>',
'            <div class="size-input">',
'              <label for="image-opacity">Image opacity:</label>',
'              <input  onChange="setImage()" type="number" step="0.1" value="0.3" id="image-opacity" class="image-opacity-input" placeholder="Opacity">',
'            </div>',
'          </div>',
'        </div>',
'        </div>',
'      </div>',
'      <button class="t-Button" type="button" onclick="alignSelectedDivs(''''vertical'''');" title="Align selected elements vertically">Align Vertically</button>',
'      <button class="t-Button" type="button" onclick="alignSelectedDivs(''''horizontal'''');" title="Align selected elements horizontally">Align Horizontally</button>',
'      <button class="t-Button" type="button" onclick="copyAndPasteDiv();" title="Create a copy of selected elements">Clone</button>',
'      <button class="t-Button" type="button" onclick="rotateSelected();" title="Rotate selected elements">Rotate</button>',
'      <button class="t-Button" type="button" onclick="deselectAll();" title="Deselect all the elements">Deselect all</button>',
'      <button class="t-Button t-Button--danger" type="button" type="button" onclick="deleteSelected();" title="Delete all the selected elements">Delete selected</button>',
'      <button class="t-Button t-Button--success" id="save-button" type="button" onclick="testProcess();" title="Save the plan into a collection">Save</button>',
'    </div>'');',
'  end if;',
'  sys.htp.p(''<div class="droppable-scroll-parent">'');',
'  if l_editable = ''N'' then ',
'    --Start of the additional container',
'    sys.htp.p(''<div class="zoom-additional-container">'');',
'  end if;',
'  sys.htp.p(''<div class="dropable-zone-body ''||l_region_id||''" id="droppable" data-app-files-path="#APP_FILES#"></div>',
'    </div>'');',
'  if l_editable = ''N'' then ',
'    --End of the additional container',
'    sys.htp.p(''</div>'');',
'    sys.htp.p(''<div class="zoom-button-container">',
'        <span onClick="showVal(-0.1);" class="zoom-button fa fa-search-minus" aria-hidden="true"></span>',
'        <span onClick="showVal(0.1);" class="zoom-button fa fa-search-plus" aria-hidden="true"></span>',
'        <span onClick="showVal(''''max'''');" class="zoom-button fa fa-layout-modal-blank" aria-hidden="true"></span>',
'      </div>'');',
'  end if;',
'  sys.htp.p(''</div>'');',
'  --',
'  if l_editable = ''Y'' then ',
'    sys.htp.p(''',
'    <div class="grid-right">',
'      <div class="type-row"> ',
'        <div class="type-select-section">',
'          <ul class="t-Tabs t-Tabs--simple a-Tabs custom-tabs" role="tablist" style="white-space: nowrap; overflow-x: hidden;">',
'      '');',
'    -- Create plan types buttons',
'    for type_rec in (select id, name from plan_type)',
'    loop',
'      sys.htp.p(''',
'      <li onClick="switchType(''|| type_rec.id ||'')" class="t-Tabs-item " role="presentation" id="''|| type_rec.id ||''">',
'        <a class="t-Tabs-link" role="tab" aria-selected="true"aria-controls="''|| type_rec.id ||''">',
'          <span>''|| type_rec.name ||''</span>',
'        </a>',
'      </li>'');',
'    end loop;',
'    sys.htp.p(''</ul>'');',
'    -- Create plan type components',
'    for type_rec in (select id, name from plan_type)',
'      loop',
'        sys.htp.p(''<div id="''||type_rec.id||''" class="components-row">'');',
'        for component_rec in (select code from type_component where plan_type_id = type_rec.id)',
'        loop',
'          sys.htp.p(component_rec.code);',
'        end loop;',
'        sys.htp.p(''</div>'');',
'    end loop;',
'   sys.htp.p(''</div>'');',
'  end if;',
' ',
' apex_javascript.add_library(p_name          => ''plugin-ajax-processes'',',
'                            p_directory      => p_plugin.file_prefix,',
'                            p_version        => NULL,',
'                            p_skip_extension => FALSE);',
'',
'/*--------------------------------------------------------',
'  Create json from plugin source and pass it to JS',
'--------------------------------------------------------*/',
'  v_json_enclave := ''{'';',
'  v_data := apex_plugin_util.get_data(',
'    p_sql_statement => p_region.source, ',
'    p_min_columns   => 1, ',
'    p_max_columns   => 50, ',
'    p_component_name => p_region.name,',
'    p_max_rows => 2000);',
'  ',
'  for i in v_data.first .. v_data(1).count loop',
'    BEGIN',
'      --Adding ID in front of object',
'      if v_data(5)(i) like ''%droppable%'' then',
'        v_object_id := ''"droppable":'';',
'      else ',
'        v_object_id := ''"''||NVL(v_data(8)(i),floor(dbms_random.value(1,1000)))||''":'';',
'      end if;',
'      v_json := v_object_id ||',
'        json_object(',
'          ''width'' value v_data(1)(i),',
'          ''height'' value v_data(2)(i),',
'          ''top'' value v_data(3)(i),',
'          ''left'' value v_data(4)(i),',
'          ''class'' value v_data(5)(i), ',
'          ''text'' value v_data(6)(i), ',
'          ''available'' value v_data(7)(i), ',
'          ''spot_id'' value v_data(8)(i), ',
'          ''rotate'' value v_data(9)(i),',
'          ''onClick'' value v_data(10)(i),',
'          ''innerHtml'' value v_data(11)(i)',
'        );',
'      if i = 1 then ',
'        v_json_enclave := v_json_enclave || v_json;',
'        htp.p(''<div class="json-data-''||l_region_id||''" data-json=''''''|| v_json ||''''''></div>'');',
'      else ',
'        v_json_enclave := v_json_enclave || '','' || v_json;',
'        htp.p(''<div class="json-data-''||l_region_id||''" data-json=''''''|| '','' || v_json ||''''''></div>'');',
'      end if;',
'    EXCEPTION WHEN OTHERS THEN ',
'        htp.p(''<div> ERROR ''||i ||'', ''|| sqlerrm || ''</div>'');',
'    END;',
'  end loop;',
'  --------------------------------------------------------',
'  v_json_enclave := v_json_enclave || ''}'';',
'  --Editable or not',
'  BEGIN',
'      if l_editable = ''Y'' then',
'        apex_javascript.add_onload_code (',
'          p_code => ''recreateFromJson(true,''||l_region_id||'');'',',
'          p_key  => l_region_id);',
'        apex_javascript.add_onload_code (',
'          p_code => ''addMobileFunctionality();'',',
'          p_key  => l_region_id);',
'      else ',
'        apex_javascript.add_onload_code (',
'          p_code => ''recreateFromJson(false,''||l_region_id||'');'',',
'          p_key  => l_region_id);',
'      end if;',
'  EXCEPTION WHEN OTHERS THEN ',
'    htp.p(''<div> ERROR '' || sqlerrm || ''</div>'');',
'    htp.p(''<div> ERROR '' || dbms_utility.format_error_backtrace || ''</div>'');',
'  END;',
'/*--------------------------------------------------------',
'  Plugin source END',
'--------------------------------------------------------*/',
'/*---------------------',
'    RENDER END',
'----------------------*/',
'  --',
'  RETURN l_result;',
'  --',
'END render_region;',
'------------------------------------------------',
'/**',
' * FUNCTION ajax_region',
' * ',
' * This function handles the AJAX request for the region.',
' * ',
' * @param p_region     IN  apex_plugin.t_region - The region object.',
' * @param p_plugin     IN  apex_plugin.t_plugin - The plugin object.',
' * ',
' * @return apex_plugin.t_region_ajax_result - The result of the AJAX request.',
' */',
'FUNCTION ajax_region(p_region IN apex_plugin.t_region,',
'                     p_plugin IN apex_plugin.t_plugin)',
'  RETURN apex_plugin.t_region_ajax_result IS',
'  -- plugin attributes',
'  l_result apex_plugin.t_region_ajax_result;',
'  l_val clob := apex_application.g_x01;',
'  l_first_batch number := apex_application.g_x02;',
'  l_query clob;',
'  l_collection_name p_region.attribute_01%TYPE := p_region.attribute_01;',
'  l_row_count number := 0;',
'  --',
'BEGIN',
'    if l_first_batch = 1 then ',
'        APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION(',
'        p_collection_name => l_collection_name);',
'    end if;',
'  --',
'  for component_rec in (',
'        select ',
'          width, height',
'          , top, left, class, text',
'          , ''Y'' as available',
'          , spot_id',
'          , rotate',
'          , innerHtml',
'        from JSON_TABLE ',
'          (l_val, ''$'' COLUMNS',
'              (NESTED path ''$.*'' COLUMNS',
'                  (',
'                      width varchar2 PATH ''$.width'',',
'                      height varchar2 PATH ''$.height'',',
'                      top varchar2 PATH ''$.top'',',
'                      left varchar2 PATH ''$.left'',',
'                      class varchar2 PATH ''$.class'',',
'                      text varchar2 PATH ''$.text'',',
'                      spot_id number PATH ''$.spotId'',',
'                      rotate varchar2 PATH ''$.rotate'',',
'                      innerHtml varchar2 PATH ''$.innerHtml''',
'                  )',
'              )',
'          ) j',
'    )',
'    loop',
'      BEGIN',
'      APEX_COLLECTION.ADD_MEMBER(',
'        p_collection_name => l_collection_name,',
'        p_c001            => component_rec.width,',
'        p_c002            => component_rec.height,',
'        p_c003            => component_rec.top,',
'        p_c004            => component_rec.left,',
'        p_c005            => component_rec.class,',
'        p_c006            => component_rec.text,',
'        p_c007            => component_rec.available,',
'        p_c008            => component_rec.spot_id,',
'        p_c009            => component_rec.rotate,',
'        p_c010            => component_rec.innerHtml',
'      );',
'      l_row_count := l_row_count + 1;',
'      EXCEPTION WHEN OTHERS THEN NULL;',
'      END;',
'    end loop;',
'  --',
'  apex_json.open_object;',
'    apex_json.write(',
'    p_name => ''success''',
'    , p_value => true',
'    );',
'    apex_json.write(',
'    p_name => ''rows_inserted''',
'    , p_value => l_row_count',
'    );',
'',
'    apex_json.close_object;',
'  RETURN l_result;',
'  --',
'END ajax_region;',
'',
'/*---------------------',
'    AJAX END',
'----------------------*/'))
,p_api_version=>2
,p_render_function=>'render_region'
,p_ajax_function=>'ajax_region'
,p_standard_attributes=>'SOURCE_LOCATION:AJAX_ITEMS_TO_SUBMIT:FETCHED_ROWS'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Pretius Drawing plugin is an interactive region plugin that helps you draw 2D plan of your parking/workspace and many more.'
,p_version_identifier=>'1.5'
,p_about_url=>'https://github.com/pretius/pretius-drawing-plugin'
,p_files_version=>234
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(15490547008014224)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Collection name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_text_case=>'UPPER'
,p_examples=>'MY_COLLECTION'
,p_help_text=>'Collection name that will be used to save the drawing'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(15490810780018409)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Editable (With Editor)'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'Y'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Choose "Yes" if you want the region to be displayed with a visible drawing editor and be editable. This allows users to interactively modify the content of the region using the provided editor.',
'',
'Choose "No" if you want the region to be displayed without a drawing editor and remain non-editable. Users will not be able to make any interactive changes to the content of the region.'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(15491181642019125)
,p_plugin_attribute_id=>wwv_flow_imp.id(15490810780018409)
,p_display_sequence=>10
,p_display_value=>'Yes'
,p_return_value=>'Y'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(15491546928019632)
,p_plugin_attribute_id=>wwv_flow_imp.id(15490810780018409)
,p_display_sequence=>20
,p_display_value=>'No'
,p_return_value=>'N'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(16528368259126348)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Left Margin'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'0'
,p_is_translatable=>false
,p_examples=>'-10'
,p_help_text=>'Drag & drop - left margin calibration. If drop of the components is inaccurate, you can adjust the left margin here in this field.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(16528998496127478)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Top Margin'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'0'
,p_is_translatable=>false
,p_examples=>'10'
,p_help_text=>'Drag & drop - top margin calibration. If drop of the components is inaccurate, you can adjust the top margin here in this field.'
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(15489758938001350)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_name=>'SOURCE_LOCATION'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220726567696F6E3D2428222E64726177696E672D706C7567696E2D626F647922292C616A61786964656E7469666965723D726567696F6E2E646174612822616A61782D6964656E74696669657222292C6973466972737442617463683D313B6675';
wwv_flow_imp.g_varchar2_table(2) := '6E6374696F6E2073656E64546F4170657828652C612C732C6E297B72657475726E206E65772050726F6D697365282828742C6F293D3E7B617065782E7365727665722E706C7567696E28616A61786964656E7469666965722C7B7830313A4A534F4E2E73';
wwv_flow_imp.g_varchar2_table(3) := '7472696E676966792865292C7830323A6973466972737442617463687D2C7B737563636573733A66756E6374696F6E2865297B636F6E736F6C652E6C6F672865292C617C7C617065782E6D6573736167652E73686F775061676553756363657373282244';
wwv_flow_imp.g_varchar2_table(4) := '726177696E67206461746120736176656420222B6E2B222F222B73292C61262628617065782E6D6573736167652E73686F7750616765537563636573732822416C6C2064726177696E67206461746120736176656420746F20636F6C6C656374696F6E20';
wwv_flow_imp.g_varchar2_table(5) := '28222B732B222922292C636F6E736F6C652E6C6F672822416C6C2064726177696E67206461746120736176656420746F20636F6C6C656374696F6E2028222B732B22292229292C6973466972737442617463683D302C742865297D2C6572726F723A6675';
wwv_flow_imp.g_varchar2_table(6) := '6E6374696F6E28652C612C73297B636F6E736F6C652E6C6F672873292C6F2873297D2C64617461547970653A226A736F6E222C6173796E633A21307D297D29297D6173796E632066756E6374696F6E207465737450726F6365737328297B76617220653D';
wwv_flow_imp.g_varchar2_table(7) := '73617665546F4A736F6E28292C613D4A534F4E2E70617273652865292C733D302C6E3D4F626A6563742E6B6579732861292E6C656E6774682C743D303B6177616974206173796E632066756E6374696F6E28297B636F6E736F6C652E6C6F672822536176';
wwv_flow_imp.g_varchar2_table(8) := '696E67206461746122293B76617220653D7B7D3B666F7228636F6E7374206F20696E206129696628612E6861734F776E50726F7065727479286F29297B636F6E737420693D615B6F5D3B696628655B6F5D3D692C282B2B732531303D3D307C7C733D3D3D';
wwv_flow_imp.g_varchar2_table(9) := '4F626A6563742E6B6579732861292E6C656E67746829262628742B3D31302C61776169742073656E64546F4170657828652C733D3D3D4F626A6563742E6B6579732861292E6C656E6774682C6E2C74292C653D7B7D2C733D3D3D4F626A6563742E6B6579';
wwv_flow_imp.g_varchar2_table(10) := '732861292E6C656E6774682929627265616B7D7D28297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(10271553916997644)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'plugin-ajax-processes.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '7661722064726F707061626C65506F736974696F6E203D202428222364726F707061626C6522292E6F666673657428293B0A2F2F636F6E736F6C652E6C6F672822546F703A2022202B2064726F707061626C65506F736974696F6E2E746F70202B20222C';
wwv_flow_imp.g_varchar2_table(2) := '204C6566743A2022202B2064726F707061626C65506F736974696F6E2E6C656674293B0A2F2A2A0A202A20456E61626C6573206472616767696E672066756E6374696F6E616C69747920666F7220636F6D706F6E656E7473206F6E206D6F62696C652064';
wwv_flow_imp.g_varchar2_table(3) := '6576696365732E0A202A2F0A66756E6374696F6E206D6F62696C6544726167436F6D706F6E656E74732829207B0A202076617220626F78203D202428272E636F6D706F6E656E742E6472616727293B0A2020666F7220286C657420696E646578203D2030';
wwv_flow_imp.g_varchar2_table(4) := '3B20696E646578203C20626F782E6C656E6774683B20696E6465782B2B29207B0A20202020636F6E737420656C656D656E74203D20626F785B696E6465785D3B0A202020206C657420636C6F6E65203D206E756C6C3B0A0A20202020656C656D656E742E';
wwv_flow_imp.g_varchar2_table(5) := '6164644576656E744C697374656E65722827746F7563687374617274272C2066756E6374696F6E20286529207B0A202020202020636C6F6E65203D20656C656D656E742E636C6F6E654E6F64652874727565293B0A202020202020636C6F6E652E737479';
wwv_flow_imp.g_varchar2_table(6) := '6C652E706F736974696F6E203D20276162736F6C757465273B0A202020202020636C6F6E652E7374796C652E6F706163697479203D202731273B0A202020202020646F63756D656E742E626F64792E617070656E644368696C6428636C6F6E65293B0A20';
wwv_flow_imp.g_varchar2_table(7) := '2020207D293B0A0A20202020656C656D656E742E6164644576656E744C697374656E65722827746F7563686D6F7665272C2066756E6374696F6E20286529207B0A20202020202076617220746F7563684C6F636174696F6E203D20652E74617267657454';
wwv_flow_imp.g_varchar2_table(8) := '6F75636865735B305D3B0A202020202020636C6F6E652E7374796C652E6C656674203D20746F7563684C6F636174696F6E2E7061676558202B20277078273B0A202020202020636C6F6E652E7374796C652E746F70203D20746F7563684C6F636174696F';
wwv_flow_imp.g_varchar2_table(9) := '6E2E7061676559202B20277078273B0A202020207D293B0A0A20202020656C656D656E742E6164644576656E744C697374656E65722827746F756368656E64272C2066756E6374696F6E20286529207B0A2020202020202F2F2047657420746865206472';
wwv_flow_imp.g_varchar2_table(10) := '6F707061626C65206469760A2020202020207661722064726F707061626C65446976203D20646F63756D656E742E676574456C656D656E7442794964282764726F707061626C6527293B0A202020202020766172206E65774964203D206D616B65696428';
wwv_flow_imp.g_varchar2_table(11) := '293B0A0A202020202020636C6F6E652E73657441747472696275746528276964272C206E65774964293B0A202020202020636C6F6E652E636C6173734C6973742E616464282772656D6F766527293B0A202020202020636C6F6E652E636C6173734C6973';
wwv_flow_imp.g_varchar2_table(12) := '742E72656D6F766528276472616727293B0A2020202020202F2F41646420696E70757420696E746F204449560A2020202020206966202828636C6F6E652E636C6173734C6973742E636F6E7461696E7328227061726B696E672D73706163652229207C7C';
wwv_flow_imp.g_varchar2_table(13) := '20636C6F6E652E636C6173734C6973742E636F6E7461696E7328227061726B696E672D73706163652D766572746963616C2229292026262021636C6F6E652E717565727953656C6563746F7228272E69642D696E707574272929207B0A20202020202020';
wwv_flow_imp.g_varchar2_table(14) := '2076617220696E707574203D20646F63756D656E742E637265617465456C656D656E742827746578746172656127293B0A2020202020202020696E7075742E736574417474726962757465282774797065272C20277465787427293B0A20202020202020';
wwv_flow_imp.g_varchar2_table(15) := '20696E7075742E7365744174747269627574652827706C616365686F6C646572272C2027456E746572207465787427293B0A2020202020202020696E7075742E636C6173734C6973742E616464282769642D696E70757427293B0A202020202020202063';
wwv_flow_imp.g_varchar2_table(16) := '6C6F6E652E617070656E644368696C6428696E707574293B0A2020202020207D0A2020202020202F2F2052656D6F76652074686520636C6F6E652066726F6D2074686520626F64790A202020202020646F63756D656E742E626F64792E72656D6F766543';
wwv_flow_imp.g_varchar2_table(17) := '68696C6428636C6F6E65293B0A0A2020202020202F2F20417070656E642074686520636C6F6E6520746F207468652064726F707061626C65206469760A20202020202064726F707061626C654469762E617070656E644368696C6428636C6F6E65293B0A';
wwv_flow_imp.g_varchar2_table(18) := '20202020202061646444726167546F456C656D656E7428636C6F6E65293B0A0A202020202020636C6F6E652E7374796C652E6C656674203D20287061727365496E7428636C6F6E652E7374796C652E6C65667429202D2064726F707061626C65506F7369';
wwv_flow_imp.g_varchar2_table(19) := '74696F6E2E6C65667429202B20277078273B0A202020202020636C6F6E652E7374796C652E746F70203D20287061727365496E7428636C6F6E652E7374796C652E746F7029202D2064726F707061626C65506F736974696F6E2E746F7029202B20277078';
wwv_flow_imp.g_varchar2_table(20) := '273B0A0A202020202020636C6F6E65203D206E756C6C3B0A202020207D293B0A20207D0A7D0A2F2A2A0A202A20456E61626C6573206472616767696E672066756E6374696F6E616C69747920666F72206578697374696E6720636F6D706F6E656E747320';
wwv_flow_imp.g_varchar2_table(21) := '6F6E206D6F62696C6520646576696365732E0A202A2F0A66756E6374696F6E206D6F62696C65447261674578697369746E672829207B0A202076617220626F78203D202428272E72656D6F76652E636F6D706F6E656E7427293B0A0A2020666F7220286C';
wwv_flow_imp.g_varchar2_table(22) := '657420696E646578203D20303B20696E646578203C20626F782E6C656E6774683B20696E6465782B2B29207B0A20202020636F6E737420656C656D656E74203D20626F785B696E6465785D3B0A2020202061646444726167546F456C656D656E7428656C';
wwv_flow_imp.g_varchar2_table(23) := '656D656E74293B0A20207D0A7D0A2F2A2A0A202A2041646473206472616767696E672066756E6374696F6E616C69747920746F206120737065636966696320656C656D656E74206F6E206D6F62696C6520646576696365732E0A202A2040706172616D20';
wwv_flow_imp.g_varchar2_table(24) := '7B48544D4C456C656D656E747D20656C656D656E74202D2054686520656C656D656E7420746F20616464206472616767696E672066756E6374696F6E616C69747920746F2E0A202A2F0A66756E6374696F6E2061646444726167546F456C656D656E7428';
wwv_flow_imp.g_varchar2_table(25) := '656C656D656E7429207B0A2020656C656D656E742E6164644576656E744C697374656E65722827746F7563686D6F7665272C2066756E6374696F6E20286529207B0A2020202076617220746F7563684C6F636174696F6E203D20652E746172676574546F';
wwv_flow_imp.g_varchar2_table(26) := '75636865735B305D3B0A20202020656C656D656E742E7374796C652E6C656674203D2028746F7563684C6F636174696F6E2E7061676558202D2064726F707061626C65506F736974696F6E2E6C65667429202B20277078273B0A20202020656C656D656E';
wwv_flow_imp.g_varchar2_table(27) := '742E7374796C652E746F70203D2028746F7563684C6F636174696F6E2E7061676559202D2064726F707061626C65506F736974696F6E2E746F7029202B20277078273B0A20207D290A7D0A0A66756E6374696F6E206164644D6F62696C6546756E637469';
wwv_flow_imp.g_varchar2_table(28) := '6F6E616C6974792829207B0A20206D6F62696C6544726167436F6D706F6E656E747328293B0A20206D6F62696C65447261674578697369746E6728293B0A7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(10695214500967773)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'mobile-functionality.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E20726563726561746546726F6D4A736F6E28652C74297B636F6E736F6C652E6C6F672822726563726561746546726F6D4A736F6E22292C743D742E69643B76617220613D2428222E6A736F6E2D646174612D222B74293B636F6E736F';
wwv_flow_imp.g_varchar2_table(2) := '6C652E6C6F67282428222E6A736F6E2D646174612D222B74292E6C656E677468293B76617220723D227B223B666F72286C657420653D303B653C612E6C656E6774683B652B2B297B636F6E737420743D615B655D3B722B3D242874292E6461746128226A';
wwv_flow_imp.g_varchar2_table(3) := '736F6E22297D722B3D227D222C6A736F6E446174613D723B766172206E3D4A534F4E2E7061727365286A736F6E44617461292C6F3D2428222364726F707061626C652E222B74293B7472797B76617220733D4F626A6563742E6B657973286E292E6C656E';
wwv_flow_imp.g_varchar2_table(4) := '6774683E303F6E2E64726F707061626C652E77696474683A646F63756D656E742E676574456C656D656E7442794964282277696E70757422292E76616C75652C6C3D4F626A6563742E6B657973286E292E6C656E6774683E303F6E2E64726F707061626C';
wwv_flow_imp.g_varchar2_table(5) := '652E6865696768743A646F63756D656E742E676574456C656D656E7442794964282268696E70757422292E76616C75653B653F6F2E637373287B77696474683A732C6865696768743A6C7D293A6F2E637373287B77696474683A732C6865696768743A6C';
wwv_flow_imp.g_varchar2_table(6) := '2C706F736974696F6E3A2272656C6174697665222C6261636B67726F756E64436F6C6F723A2223656565227D297D63617463682865297B636F6E736F6C652E6C6F6728224E6F20696E7075747322297D666F7228766172206920696E206E296966282264';
wwv_flow_imp.g_varchar2_table(7) := '726F707061626C6522213D3D69297B76617220633D6E5B695D2C643D2428273C64697620636C6173733D2272656D6F76652220272B282259223D3D3D632E617661696C61626C653F276F6E436C69636B3D22272B632E6F6E436C69636B2B2722273A2222';
wwv_flow_imp.g_varchar2_table(8) := '292B223E3C2F6469763E22293B69662865262628643D2428273C64697620636C6173733D2272656D6F766522206F6E436C69636B3D2273656C65637428293B223E3C2F6469763E2729292C642E637373287B77696474683A632E77696474682C68656967';
wwv_flow_imp.g_varchar2_table(9) := '68743A632E6865696768742C746F703A632E746F702C6C6566743A632E6C6566742C726F746174653A632E726F746174652C706F736974696F6E3A226162736F6C757465227D292C642E6174747228226964222C69292C642E616464436C61737328632E';
wwv_flow_imp.g_varchar2_table(10) := '636C617373292C616464496E707574416E64417661696C6162696C697479436C61737328642C63292C61646444697669636F6E732864292C6F2E617070656E642864292C632E636C6173732E696E636C7564657328227061726B696E672D737061636522';
wwv_flow_imp.g_varchar2_table(11) := '297C7C632E636C6173732E696E636C7564657328227061726B696E672D73706163652D766572746963616C22297C7C632E636C6173732E696E636C7564657328226C6162656C2229293B656C7365207472797B645B305D2E696E7365727441646A616365';
wwv_flow_imp.g_varchar2_table(12) := '6E7448544D4C28226265666F7265656E64222C632E696E6E657248746D6C2E7265706C616365416C6C282240222C27222729297D63617463682865297B636F6E736F6C652E6C6F6728224E6F20696E6E65722068746D6C22297D7D653F282428222E7265';
wwv_flow_imp.g_varchar2_table(13) := '6D6F766522292E726573697A61626C65287B677269643A5B312C315D7D292E647261676761626C65287B677269643A5B312C315D7D292C6164644D6F62696C6546756E6374696F6E616C6974792829293A242822237772617070657222292E617070656E';
wwv_flow_imp.g_varchar2_table(14) := '64286F293B7472797B76617220703D646F63756D656E742E717565727953656C6563746F7228222377696E70757422292C673D646F63756D656E742E717565727953656C6563746F7228222368696E70757422293B702E76616C75653D732C672E76616C';
wwv_flow_imp.g_varchar2_table(15) := '75653D6C7D63617463682865297B636F6E736F6C652E6C6F6728224E6F20696E7075747322297D2428222E72656D6F766522292E62696E6428226472616773746F70222C2866756E6374696F6E28297B73656C6563742874686973297D29297D66756E63';
wwv_flow_imp.g_varchar2_table(16) := '74696F6E2073617665546F4A736F6E28297B76617220653D7B7D2C743D2428222364726F707061626C6522292C613D7B77696474683A242874292E6373732822776964746822292C6865696768743A242874292E637373282268656967687422292C746F';
wwv_flow_imp.g_varchar2_table(17) := '703A22307078222C6C6566743A22307078222C636C6173733A742E617474722822636C61737322292C73706F7449643A742E69647D3B72657475726E20652E64726F707061626C653D612C2428222E72656D6F766522292E65616368282866756E637469';
wwv_flow_imp.g_varchar2_table(18) := '6F6E28297B76617220743D746869732E69642C613D7B77696474683A4D6174682E726F756E64287061727365466C6F617428242874686973292E63737328227769647468222929292B227078222C6865696768743A4D6174682E726F756E642870617273';
wwv_flow_imp.g_varchar2_table(19) := '65466C6F617428242874686973292E6373732822686569676874222929292B227078222C746F703A4D6174682E726F756E64287061727365466C6F617428242874686973292E6373732822746F70222929292B227078222C6C6566743A4D6174682E726F';
wwv_flow_imp.g_varchar2_table(20) := '756E64287061727365466C6F617428242874686973292E63737328226C656674222929292B227078222C636C6173733A242874686973292E617474722822636C61737322292C746578743A242874686973292E66696E642822746578746172656122292E';
wwv_flow_imp.g_varchar2_table(21) := '76616C28292C726F746174653A242874686973292E6373732822726F7461746522292C73706F7449643A742C696E6E657248746D6C3A746869732E696E6E657248544D4C2E7265706C616365416C6C282722272C224022292E7265706C616365282F285C';
wwv_flow_imp.g_varchar2_table(22) := '725C6E7C5C6E7C5C72292F676D2C2222297D3B655B745D3D617D29292C4A534F4E2E737472696E676966792865297D66756E6374696F6E206368616E676553697A6528297B76617220653D646F63756D656E742E676574456C656D656E74427949642822';
wwv_flow_imp.g_varchar2_table(23) := '77696E70757422292E76616C75652C743D646F63756D656E742E676574456C656D656E7442794964282268696E70757422292E76616C75653B2428222364726F707061626C6522292E63737328227769647468222C65292C2428222364726F707061626C';
wwv_flow_imp.g_varchar2_table(24) := '6522292E6373732822686569676874222C74297D66756E6374696F6E206D616B65696428297B72657475726E226E65772D69642D222B4D6174682E72616E646F6D28292E746F537472696E67283336292E73756273747228322C39297D66756E6374696F';
wwv_flow_imp.g_varchar2_table(25) := '6E2070726570617265456469746F7228297B76617220653D6E756C6C3B2428222E6472616722292E647261676761626C65287B68656C7065723A22636C6F6E65222C637572736F723A226D6F7665222C746F6C6572616E63653A22666974222C72657665';
wwv_flow_imp.g_varchar2_table(26) := '72743A21302C677269643A5B312C315D7D292C2428222364726F707061626C6522292E64726F707061626C65287B6163636570743A222E64726167222C616374697665436C6173733A2264726F702D61726561222C64726F703A66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(27) := '2C61297B6966282264726167223D3D2428612E647261676761626C65295B305D2E6964297B653D612E68656C7065722E636C6F6E6528292C612E68656C7065722E72656D6F766528292C652E647261676761626C65287B68656C7065723A226F72696769';
wwv_flow_imp.g_varchar2_table(28) := '6E616C222C637572736F723A226D6F7665222C746F6C6572616E63653A22666974222C64726F703A66756E6374696F6E28652C74297B2428742E647261676761626C65292E72656D6F766528297D2C647261673A66756E6374696F6E28652C74297B742E';
wwv_flow_imp.g_varchar2_table(29) := '706F736974696F6E7D2C677269643A5B312C315D7D292C652E726573697A61626C65287B677269643A5B312C315D7D293B76617220723D6D616B65696428293B696628652E6174747228226964222C72292C652E616464436C617373282272656D6F7665';
wwv_flow_imp.g_varchar2_table(30) := '22292C652E72656D6F7665436C61737328226472616722292C28652E686173436C61737328227061726B696E672D737061636522297C7C652E686173436C61737328227061726B696E672D73706163652D766572746963616C222929262621652E66696E';
wwv_flow_imp.g_varchar2_table(31) := '6428222E69642D696E70757422292E6C656E677468297B766172206E3D2428273C746578746172656120747970653D22746578742220706C616365686F6C6465723D22456E74657220746578742220636C6173733D2269642D696E707574222F3E27293B';
wwv_flow_imp.g_varchar2_table(32) := '652E617070656E64286E297D652E617070656E64546F28222364726F707061626C6522292C2428222E64656C65746522292E6F6E2822636C69636B222C2866756E6374696F6E28297B242874686973292E706172656E7428292E706172656E7428227370';
wwv_flow_imp.g_varchar2_table(33) := '616E22292E72656D6F766528297D29292C2428222E64656C65746522292E706172656E7428292E706172656E7428227370616E22292E64626C636C69636B282866756E6374696F6E28297B242874686973292E72656D6F766528297D29293B766172206F';
wwv_flow_imp.g_varchar2_table(34) := '3D4E756D62657228655B305D2E6F66667365744C656674292C733D4E756D62657228655B305D2E6F6666736574546F70293B652E6373732822706F736974696F6E222C226162736F6C75746522293B766172206C3D2428222E64726177696E672D706C75';
wwv_flow_imp.g_varchar2_table(35) := '67696E2D626F647922292E706172656E7428292E63737328226D617267696E4C65667422292E7265706C61636528227078222C2222292C693D2428222E64726177696E672D706C7567696E2D626F647922292E706172656E7428292C633D28242869295B';
wwv_flow_imp.g_varchar2_table(36) := '305D2E676574426F756E64696E67436C69656E745265637428292E746F702C2428222E64726F70646F776E22292E6461746128226C6566744D617267696E2229292C643D2428222E64726F70646F776E22292E646174612822746F704D617267696E2229';
wwv_flow_imp.g_varchar2_table(37) := '3B652E63737328226C656674222C6F2D6C2B63292C652E6373732822746F70222C732D64292C652E62696E6428226472616773746F70222C2866756E6374696F6E28297B73656C6563742874686973297D29297D7D7D292C2428222372656D6F76652D64';
wwv_flow_imp.g_varchar2_table(38) := '72616722292E64726F707061626C65287B64726F703A66756E6374696F6E28652C74297B2428742E647261676761626C65292E72656D6F766528297D2C686F766572436C6173733A2272656D6F76652D647261672D686F766572222C6163636570743A22';
wwv_flow_imp.g_varchar2_table(39) := '2E72656D6F7665227D293B636F6E737420743D646F63756D656E742E717565727953656C6563746F7228222377696E70757422292C613D646F63756D656E742E717565727953656C6563746F7228222368696E70757422293B7472797B742E6164644576';
wwv_flow_imp.g_varchar2_table(40) := '656E744C697374656E657228226368616E6765222C28653D3E7B6368616E676553697A6528297D29292C612E6164644576656E744C697374656E657228226368616E6765222C28653D3E7B6368616E676553697A6528297D29297D63617463682865297B';
wwv_flow_imp.g_varchar2_table(41) := '7D7D66756E6374696F6E2061646444697669636F6E732865297B76617220743D7B226172726F772D6C656674223A2266612066612D6172726F772D6C656674222C226172726F772D7269676874223A2266612066612D6172726F772D7269676874222C22';
wwv_flow_imp.g_varchar2_table(42) := '6172726F772D7570223A2266612066612D6172726F772D7570222C226172726F772D646F776E223A2266612066612D6172726F772D646F776E222C226172726F772D696E2D65617374223A2266612066612D626F782D6172726F772D696E2D6561737422';
wwv_flow_imp.g_varchar2_table(43) := '2C227061726B696E672D73706163652D70617261706C65676963223A2266612066612D776865656C6368616972227D3B72657475726E20652E65616368282866756E6374696F6E28297B666F7228766172206520696E207429696628242874686973292E';
wwv_flow_imp.g_varchar2_table(44) := '686173436C617373286529297B76617220613D2428273C6920636C6173733D22272B745B655D2B27223E3C2F693E27293B242874686973292E617070656E642861293B627265616B7D7D29292C657D66756E6374696F6E20616464496E707574416E6441';
wwv_flow_imp.g_varchar2_table(45) := '7661696C6162696C697479436C61737328652C74297B696628652E686173436C61737328227061726B696E672D737061636522297C7C652E686173436C61737328227061726B696E672D73706163652D766572746963616C22297C7C652E686173436C61';
wwv_flow_imp.g_varchar2_table(46) := '737328226C6162656C2229297B76617220613D2428273C746578746172656120747970653D22746578742220706C616365686F6C6465723D222220636C6173733D2269642D696E707574222F3E27293B612E76616C28742E74657874292C652E61707065';
wwv_flow_imp.g_varchar2_table(47) := '6E642861293B76617220723D7B593A22617661696C61626C65222C4E3A226E6F742D617661696C61626C65222C523A227265736572766564227D5B742E617661696C61626C655D7C7C22223B652E686173436C61737328226C6162656C22297C7C652E61';
wwv_flow_imp.g_varchar2_table(48) := '6464436C6173732872297D7D66756E6374696F6E20726F7461746528652C74297B76617220613D747C7C31302C723D242865292E706172656E7428292C6E3D722E6373732822726F7461746522293B696628226E6F6E65223D3D6E29722E637373282272';
wwv_flow_imp.g_varchar2_table(49) := '6F74617465222C612B2264656722293B656C73657B286E3D6E2E6D61746368282F5C642B2F295B305D292E746F537472696E6728293B766172206F3D4E756D626572286E292B4E756D6265722861293B722E6373732822726F74617465222C6F2B226465';
wwv_flow_imp.g_varchar2_table(50) := '6722297D7D66756E6374696F6E20736574496D61676528297B76617220653D646F63756D656E742E676574456C656D656E74427949642822696D6167652D7061746822292E76616C75652C743D646F63756D656E742E676574456C656D656E7442794964';
wwv_flow_imp.g_varchar2_table(51) := '282264726F707061626C6522292C613D312D646F63756D656E742E676574456C656D656E74427949642822696D6167652D6F70616369747922292E76616C75652C723D646F63756D656E742E676574456C656D656E7442794964282264726F707061626C';
wwv_flow_imp.g_varchar2_table(52) := '6522292E6765744174747269627574652822646174612D6170702D66696C65732D7061746822293B646F63756D656E742E676574456C656D656E744279496428226261636B67726F756E642D73776974636822292E636865636B65643F28742E7374796C';
wwv_flow_imp.g_varchar2_table(53) := '652E6261636B67726F756E64496D6167653D226C696E6561722D6772616469656E74282072676261283235352C3235352C3235352C222B612B22292C2072676261283235352C3235352C3235352C222B612B2229292C2075726C2827222B722B652B2227';
wwv_flow_imp.g_varchar2_table(54) := '29222C742E7374796C652E6261636B67726F756E6453697A653D2231303025203130302522293A28742E7374796C652E6261636B67726F756E64496D6167653D22222C742E7374796C652E6261636B67726F756E6453697A653D2222297D66756E637469';
wwv_flow_imp.g_varchar2_table(55) := '6F6E2073656C6563742865297B696628652976617220743D653B656C736520743D746869732E6576656E742E7461726765743B21242874292E636C6F7365737428222E636F6D706F6E656E74732D726F7722292E6C656E6774683E30262628242874292E';
wwv_flow_imp.g_varchar2_table(56) := '686173436C617373282275692D726573697A61626C652D68616E646C6522297C7C28242874292E686173436C6173732822636F6D706F6E656E7422297C7C242874292E686173436C617373282269642D696E70757422297C7C242874292E686173436C61';
wwv_flow_imp.g_varchar2_table(57) := '7373282269676E6F72652D73656C656374656422297C7C28743D242874292E636C6F7365737428222E636F6D706F6E656E742229292C242874292E686173436C617373282273656C656374656422293F242874292E72656D6F7665436C61737328227365';
wwv_flow_imp.g_varchar2_table(58) := '6C656374656422293A242874292E686173436C6173732822636F6D706F6E656E7422293F242874292E616464436C617373282273656C656374656422293A242874292E686173436C6173732822636F6D706F6E656E7422297C7C242874292E66696E6428';
wwv_flow_imp.g_varchar2_table(59) := '222E636F6D706F6E656E7422292E616464436C617373282273656C6563746564222929297D66756E6374696F6E20646573656C656374416C6C28297B41727261792E66726F6D282428222E73656C65637465642229292E666F72456163682828653D3E7B';
wwv_flow_imp.g_varchar2_table(60) := '242865292E72656D6F7665436C617373282273656C656374656422297D29297D66756E6374696F6E20616C69676E53656C6563746564446976732865297B636F6E737420743D646F63756D656E742E717565727953656C6563746F72416C6C28222E7365';
wwv_flow_imp.g_varchar2_table(61) := '6C656374656422293B69662830213D3D742E6C656E6774682969662822686F72697A6F6E74616C223D3D3D65297B6C657420653D303B666F7228636F6E73742061206F662074297B652B3D612E676574426F756E64696E67436C69656E74526563742829';
wwv_flow_imp.g_varchar2_table(62) := '2E6C6566747D636F6E737420613D652F742E6C656E6774683B666F7228636F6E73742065206F662074297B636F6E737420743D652E676574426F756E64696E67436C69656E745265637428292E6C6566742C723D612D743B652E7374796C652E6C656674';
wwv_flow_imp.g_varchar2_table(63) := '3D60247B742B727D7078607D7D656C73652069662822766572746963616C223D3D3D65297B6C657420653D303B666F7228636F6E73742061206F662074297B652B3D612E676574426F756E64696E67436C69656E745265637428292E746F707D636F6E73';
wwv_flow_imp.g_varchar2_table(64) := '7420613D652F742E6C656E6774683B666F7228636F6E73742065206F662074297B636F6E737420743D652E676574426F756E64696E67436C69656E745265637428292E746F702C723D612D743B652E7374796C652E746F703D60247B742B727D7078607D';
wwv_flow_imp.g_varchar2_table(65) := '7D656C736520636F6E736F6C652E6572726F722827496E76616C6964206178697320706172616D657465722E20506C65617365207573652022686F72697A6F6E74616C22206F722022766572746963616C222E27297D66756E6374696F6E20636F707941';
wwv_flow_imp.g_varchar2_table(66) := '6E64506173746544697628297B76617220653D41727261792E66726F6D282428222E73656C65637465642229293B646573656C656374416C6C28292C652E666F72456163682828653D3E7B636F6E737420743D652E636C6F6E654E6F6465282130293B74';
wwv_flow_imp.g_varchar2_table(67) := '2E636C6173734C6973742E616464282273656C656374656422293B76617220613D6D616B65696428293B742E69643D612C2428222364726F707061626C6522292E617070656E642874292C242874292E647261676761626C65287B677269643A5B312C31';
wwv_flow_imp.g_varchar2_table(68) := '5D7D292C242874292E62696E6428226472616773746F70222C2866756E6374696F6E28297B73656C6563742874686973297D29297D29297D66756E6374696F6E2064656C65746553656C656374656428297B2428222E73656C656374656422292E72656D';
wwv_flow_imp.g_varchar2_table(69) := '6F766528297D66756E6374696F6E20726F7461746553656C656374656428297B76617220653D2428222E73656C656374656422293B666F72286C657420723D303B723C652E6C656E6774683B722B2B297B636F6E7374206E3D655B725D3B76617220743D';
wwv_flow_imp.g_varchar2_table(70) := '24286E292E6373732822726F7461746522293B69662822333630646567223D3D74262628743D226E6F6E6522292C226E6F6E65223D3D742924286E292E6373732822726F74617465222C22343564656722293B656C73657B28743D742E6D61746368282F';
wwv_flow_imp.g_varchar2_table(71) := '5C642B2F295B305D292E746F537472696E6728293B76617220613D4E756D6265722874292B4E756D626572283435293B24286E292E6373732822726F74617465222C612B2264656722297D7D7D70726570617265456469746F7228293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(10696518661995058)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'map.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E66612D706C75732D7371756172657B636F6C6F723A677265656E7D2E742D427574746F6E526567696F6E2D636F6C2D2D636F6E74656E747B646973706C61793A666C65787D6C697B6C6973742D7374796C652D747970653A6E6F6E657D2E6C697B6D61';
wwv_flow_imp.g_varchar2_table(2) := '7267696E2D746F703A313270787D756C206C697B6C6973742D7374796C653A6E6F6E657D2E647261672D6C69737420696D677B77696474683A383070783B6865696768743A383070783B766572746963616C2D616C69676E3A6D6964646C653B63757273';
wwv_flow_imp.g_varchar2_table(3) := '6F723A6D6F76657D2E647261672D6C69737420756C7B6D617267696E3A303B70616464696E673A307D2E647261672D6C697374206C692C2E6C697B6D617267696E2D626F74746F6D3A3570787D6C692E686F72697A6F6E74616C7B70616464696E673A35';
wwv_flow_imp.g_varchar2_table(4) := '707820303B6865696768743A353070783B6C6973742D7374796C652D747970653A6E6F6E657D2E736570617261746F727B77696474683A313070783B6865696768743A353070783B666C6F61743A6C6566747D2E6E6F742D73656C65637461626C657B70';
wwv_flow_imp.g_varchar2_table(5) := '6F696E7465722D6576656E74733A6E6F6E657D2E747970652D73656C6563742D73656374696F6E7B6D617267696E2D626F74746F6D3A313070787D2364726F707061626C657B77696474683A35353070783B6865696768743A35343070783B626F726465';
wwv_flow_imp.g_varchar2_table(6) := '723A31707820736F6C696420233030307D2E677269642D6261636B67726F756E647B2D2D733A31303070783B2D2D5F673A23303030302039306465672C20726762283230392C203233342C203234352920303B6261636B67726F756E643A636F6E69632D';
wwv_flow_imp.g_varchar2_table(7) := '6772616469656E742866726F6D20393064656720617420327078203270782C766172282D2D5F6729293020302F766172282D2D732920766172282D2D73292C636F6E69632D6772616469656E742866726F6D20393064656720617420317078203170782C';
wwv_flow_imp.g_varchar2_table(8) := '766172282D2D5F6729293020302F63616C6328766172282D2D73292F35292063616C6328766172282D2D73292F35297D2E72696768747B666C6F61743A72696768747D2E6C6566747B666C6F61743A6C6566747D2E636C6561727B636C6561723A626F74';
wwv_flow_imp.g_varchar2_table(9) := '687D2E72656D6F76652D647261672D686F7665727B6261636B67726F756E642D636F6C6F723A2365643439343921696D706F7274616E747D2E647261677B726573697A653A626F74683B6F766572666C6F773A6175746F7D2E69642D696E7075747B7465';
wwv_flow_imp.g_varchar2_table(10) := '78742D616C69676E3A72696768743B77696474683A63616C632831303025202D2031307078293B6261636B67726F756E642D636F6C6F723A236164643865363B626F726465723A2E35707820736F6C696420677261797D2E72656D6F76657B6F76657266';
wwv_flow_imp.g_varchar2_table(11) := '6C6F773A68696464656E7D2E627574746F6E2D64726F70646F776E2D6D61707B6D617267696E2D72696768743A35707821696D706F7274616E747D2E64726F70646F776E7B706F736974696F6E3A72656C61746976653B646973706C61793A696E6C696E';
wwv_flow_imp.g_varchar2_table(12) := '652D626C6F636B7D2E64726F70646F776E2D636F6E74656E747B646973706C61793A6E6F6E653B706F736974696F6E3A6162736F6C7574653B6261636B67726F756E642D636F6C6F723A236631663166313B6D696E2D77696474683A32303070783B6F76';
wwv_flow_imp.g_varchar2_table(13) := '6572666C6F773A6175746F3B626F782D736861646F773A302038707820313670782030207267626128302C302C302C2E32293B7A2D696E6465783A317D2E64726F70646F776E2D696E6E65727B70616464696E673A323070787D2E64726F70646F776E2D';
wwv_flow_imp.g_varchar2_table(14) := '696E6E65723E627574746F6E7B77696474683A313030257D2E73686F777B646973706C61793A626C6F636B7D2E73697A652D696E7075747B6D617267696E2D626F74746F6D3A3570787D756C2E637573746F6D2D746162737B6D617267696E2D626F7474';
wwv_flow_imp.g_varchar2_table(15) := '6F6D3A3470787D2E766572746963616C7B726F746174653A39306465677D2373697A652D73657474696E67732C2E636F6D706F6E656E747B6D617267696E3A313070787D2E636F6D706F6E656E74732D726F772C2E73656C6563742D747970657B626F72';
wwv_flow_imp.g_varchar2_table(16) := '6465723A31707820736F6C696420236435643564353B626F726465722D7261646975733A3570787D2E636F6D706F6E656E74732D726F777B646973706C61793A666C65783B77696474683A313030253B666C65782D646972656374696F6E3A726F773B66';
wwv_flow_imp.g_varchar2_table(17) := '6C65782D777261703A777261707D2E73656C6563742D747970657B77696474683A6175746F3B70616464696E673A313070783B6D617267696E2D72696768743A313070783B6261636B67726F756E642D636F6C6F723A236666663B666C6F61743A6C6566';
wwv_flow_imp.g_varchar2_table(18) := '747D2E747970652D73656C6563742D73656374696F6E7B646973706C61793A666C65783B666C65782D646972656374696F6E3A726F773B666C65782D777261703A777261707D2E73656C6563742D747970652E6163746976657B6261636B67726F756E64';
wwv_flow_imp.g_varchar2_table(19) := '2D636F6C6F723A233565626666667D2E75692D64726F707061626C652D6163746976657B6261636B67726F756E642D636F6C6F723A7472616E73706172656E7421696D706F7274616E747D2E677269642D6C6566747B6D61782D77696474683A3730253B';
wwv_flow_imp.g_varchar2_table(20) := '666C6F61743A6C6566747D2E677269642D72696768747B6D696E2D77696474683A3330253B666C6F61743A6C6566743B6D617267696E2D6C6566743A313270783B6D617267696E2D746F703A343570787D2E73656C65637465647B6F75746C696E653A74';
wwv_flow_imp.g_varchar2_table(21) := '6869636B20736F6C696420233930656539307D2E696E707574737B77696474683A373070787D2E64726177696E672D706C7567696E2D626F64792C2E6C6566742D736964652D627574746F6E737B646973706C61793A666C65783B666C65782D64697265';
wwv_flow_imp.g_varchar2_table(22) := '6374696F6E3A726F777D2E64726F707061626C652D7363726F6C6C2D706172656E747B6F766572666C6F772D793A6175746F7D2E64726F7061626C652D7A6F6E652D626F64797B706F736974696F6E3A72656C61746976653B6D617267696E2D746F703A';
wwv_flow_imp.g_varchar2_table(23) := '3870787D2E742D546162732D6974656D2C2E742D546162732D6C696E6B7B637572736F723A706F696E74657221696D706F7274616E747D236D617053657474696E677344726F70646F776E3E6469763E6469763A6E74682D6368696C642831293E6C6162';
wwv_flow_imp.g_varchar2_table(24) := '656C7B6D617267696E2D72696768743A3570787D2E677269642D66756C6C2D7370616E7B77696474683A3130302521696D706F7274616E743B666C6F61743A6C6566747D2E636F6D706F6E656E743E74657874617265612C2E72656D6F76653E74657874';
wwv_flow_imp.g_varchar2_table(25) := '617265617B77696474683A3930253B6865696768743A3930253B746578742D616C69676E3A72696768747D2E73657474696E67732D6C6162656C7B666F6E742D7765696768743A3730303B70616464696E673A327078203020307D2E7A6F6F6D2D616464';
wwv_flow_imp.g_varchar2_table(26) := '6974696F6E616C2D636F6E7461696E65727B6D617267696E3A6175746F7D2E7A6F6F6D2D627574746F6E2D636F6E7461696E65727B666C6F61743A72696768743B6D617267696E2D72696768743A313070783B6D617267696E2D746F703A313070787D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(11916651655219343)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'global.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E20737769746368547970652865297B766172206F3D24286064697623247B657D2E636F6D706F6E656E74732D726F7760293B2428222E636F6D706F6E656E74732D726F7722292E6869646528292C6F2E73686F7728293B7661722074';
wwv_flow_imp.g_varchar2_table(2) := '3D606C6923247B657D603B2428226C692E742D546162732D6974656D22292E72656D6F7665436C6173732822612D546162732D73656C656374656422292C2428226C692E742D546162732D6974656D22292E72656D6F7665436C617373282269732D6163';
wwv_flow_imp.g_varchar2_table(3) := '7469766522292C242874292E616464436C6173732822612D546162732D73656C656374656422292C242874292E616464436C617373282269732D61637469766522297D66756E6374696F6E2073686F774772696428297B2428222364726F707061626C65';
wwv_flow_imp.g_varchar2_table(4) := '22292E686173436C6173732822677269642D6261636B67726F756E6422293F2428222364726F707061626C6522292E72656D6F7665436C6173732822677269642D6261636B67726F756E6422293A2428222364726F707061626C6522292E616464436C61';
wwv_flow_imp.g_varchar2_table(5) := '73732822677269642D6261636B67726F756E6422297D66756E6374696F6E20746F67676C654D617053657474696E677328297B646F63756D656E742E676574456C656D656E744279496428226D617053657474696E677344726F70646F776E22292E636C';
wwv_flow_imp.g_varchar2_table(6) := '6173734C6973742E746F67676C65282273686F7722297D766172207A6F6F6D5363616C653D313B66756E6374696F6E207365745A6F6F6D28652C6F297B7472616E73666F726D4F726967696E3D5B302C305D3B666F722876617220743D5B227765626B69';
wwv_flow_imp.g_varchar2_table(7) := '74222C226D6F7A222C226D73222C226F225D2C613D227363616C6528222B652B2229222C733D3130302A7472616E73666F726D4F726967696E5B305D2B222520222B3130302A7472616E73666F726D4F726967696E5B315D2B2225222C723D303B723C74';
wwv_flow_imp.g_varchar2_table(8) := '2E6C656E6774683B722B2B296F2E7374796C655B745B725D2B225472616E73666F726D225D3D612C6F2E7374796C655B745B725D2B225472616E73666F726D4F726967696E225D3D733B6F2E7374796C652E7472616E73666F726D3D612C6F2E7374796C';
wwv_flow_imp.g_varchar2_table(9) := '652E7472616E73666F726D4F726967696E3D737D66756E6374696F6E2073686F7756616C2865297B766172206F3D303B7472797B696628226D6178223D3D65297B76617220743D5B5D2C613D646F63756D656E742E717565727953656C6563746F722822';
wwv_flow_imp.g_varchar2_table(10) := '2E7A6F6F6D2D6164646974696F6E616C2D636F6E7461696E657222293B61262628743D5B612E6F666673657457696474682C612E6F66667365744865696768745D293B76617220733D5B5D2C723D646F63756D656E742E717565727953656C6563746F72';
wwv_flow_imp.g_varchar2_table(11) := '28222E64726F7061626C652D7A6F6E652D626F647922293B72262628733D5B722E6F666673657457696474682C722E6F66667365744865696768745D292C6F3D4D6174682E6D696E284D6174682E61627328745B305D2F735B305D292C4D6174682E6162';
wwv_flow_imp.g_varchar2_table(12) := '7328745B315D2F735B315D29297D7D63617463682865297B636F6E736F6C652E6C6F672865297D30213D3D6F3F7A6F6F6D5363616C653D6F3A7A6F6F6D5363616C652B3D4E756D6265722865292C7365745A6F6F6D287A6F6F6D5363616C652C646F6375';
wwv_flow_imp.g_varchar2_table(13) := '6D656E742E676574456C656D656E74734279436C6173734E616D65282264726F7061626C652D7A6F6E652D626F647922295B305D297D646F63756D656E742E717565727953656C6563746F72416C6C28222E64726F7061626C652D7A6F6E652D626F6479';
wwv_flow_imp.g_varchar2_table(14) := '22292E666F72456163682828653D3E7B652E6164644576656E744C697374656E65722822636C69636B222C2866756E6374696F6E2865297B652E7461726765743D3D3D746869732626646573656C656374416C6C28297D29297D29292C73686F77477269';
wwv_flow_imp.g_varchar2_table(15) := '6428292C737769746368547970652831292C73686F7756616C2830293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(11926076248092891)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'control-functions.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220726567696F6E203D202428272E64726177696E672D706C7567696E2D626F647927293B0A76617220616A61786964656E746966696572203D20726567696F6E2E646174612822616A61782D6964656E74696669657222293B0A2F2F0A76617220';
wwv_flow_imp.g_varchar2_table(2) := '697346697273744261746368203D20313B0A2F2F0A66756E6374696F6E2073656E64546F4170657828646174612C2069734C61737442617463682C746F74616C436F756E742C7361766564436F756E7429207B0A2020202072657475726E206E65772050';
wwv_flow_imp.g_varchar2_table(3) := '726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0A2020202020202020617065782E7365727665722E706C7567696E280A202020202020202020202020616A61786964656E7469666965722C0A2020202020202020202020207B0A';
wwv_flow_imp.g_varchar2_table(4) := '202020202020202020202020202020207830313A204A534F4E2E737472696E676966792864617461292C0A202020202020202020202020202020207830323A206973466972737442617463680A2020202020202020202020207D2C0A2020202020202020';
wwv_flow_imp.g_varchar2_table(5) := '202020207B0A20202020202020202020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0A2020202020202020202020202020202020202020636F6E736F6C652E6C6F67287044617461293B0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(6) := '20202020202020202020696620282169734C6173744261746368297B0A202020202020202020202020202020202020202020202020617065782E6D6573736167652E73686F775061676553756363657373282744726177696E6720646174612073617665';
wwv_flow_imp.g_varchar2_table(7) := '642027202B207361766564436F756E74202B20272F27202B20746F74616C436F756E74293B0A20202020202020202020202020202020202020207D0A20202020202020202020202020202020202020206966202869734C617374426174636829207B0A20';
wwv_flow_imp.g_varchar2_table(8) := '2020202020202020202020202020202020202020202020617065782E6D6573736167652E73686F7750616765537563636573732827416C6C2064726177696E67206461746120736176656420746F20636F6C6C656374696F6E2028272B746F74616C436F';
wwv_flow_imp.g_varchar2_table(9) := '756E742B272927293B0A202020202020202020202020202020202020202020202020636F6E736F6C652E6C6F672827416C6C2064726177696E67206461746120736176656420746F20636F6C6C656374696F6E2028272B746F74616C436F756E742B2729';
wwv_flow_imp.g_varchar2_table(10) := '27293B0A20202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020697346697273744261746368203D20303B0A20202020202020202020202020202020202020207265736F6C7665287044617461293B0A';
wwv_flow_imp.g_varchar2_table(11) := '202020202020202020202020202020207D2C0A202020202020202020202020202020206572726F723A2066756E6374696F6E20286A715848522C20746578745374617475732C206572726F725468726F776E29207B0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(12) := '202020202020636F6E736F6C652E6C6F67286572726F725468726F776E293B0A202020202020202020202020202020202020202072656A656374286572726F725468726F776E293B0A202020202020202020202020202020207D2C0A2020202020202020';
wwv_flow_imp.g_varchar2_table(13) := '202020202020202064617461547970653A20276A736F6E272C0A202020202020202020202020202020206173796E633A20747275650A2020202020202020202020207D0A2020202020202020293B0A202020207D293B0A7D0A0A6173796E632066756E63';
wwv_flow_imp.g_varchar2_table(14) := '74696F6E207465737450726F636573732829207B0A20202020766172206A736F6E44617461203D2073617665546F4A736F6E28293B0A202020200A2020202076617220796F75724A534F4E4F626A656374203D204A534F4E2E7061727365286A736F6E44';
wwv_flow_imp.g_varchar2_table(15) := '617461293B0A202020207661722069203D20303B0A2020202076617220746F74616C436F756E74203D204F626A6563742E6B65797328796F75724A534F4E4F626A656374292E6C656E6774683B0A20202020766172207361766564436F756E74203D2030';
wwv_flow_imp.g_varchar2_table(16) := '3B0A0A202020206173796E632066756E6374696F6E2073656E6442617463682829207B0A2020202020202020636F6E736F6C652E6C6F672827536176696E67206461746127293B0A2020202020202020766172206A736F6E416767203D207B7D3B0A2020';
wwv_flow_imp.g_varchar2_table(17) := '202020202020666F722028636F6E7374206B657920696E20796F75724A534F4E4F626A65637429207B0A20202020202020202020202069662028796F75724A534F4E4F626A6563742E6861734F776E50726F7065727479286B65792929207B0A20202020';
wwv_flow_imp.g_varchar2_table(18) := '202020202020202020202020636F6E7374206F626A203D20796F75724A534F4E4F626A6563745B6B65795D3B0A202020202020202020202020202020206A736F6E4167675B6B65795D203D206F626A3B0A20202020202020202020202020202020692B2B';
wwv_flow_imp.g_varchar2_table(19) := '3B0A2020202020202020202020202020202069662028692025203130203D3D3D2030207C7C2069203D3D3D204F626A6563742E6B65797328796F75724A534F4E4F626A656374292E6C656E67746829207B0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(20) := '20207361766564436F756E74202B3D2031303B0A202020202020202020202020202020202020202061776169742073656E64546F41706578286A736F6E4167672C2069203D3D3D204F626A6563742E6B65797328796F75724A534F4E4F626A656374292E';
wwv_flow_imp.g_varchar2_table(21) := '6C656E6774682C746F74616C436F756E742C7361766564436F756E74293B0A20202020202020202020202020202020202020206A736F6E416767203D207B7D3B0A20202020202020202020202020202020202020206966202869203D3D3D204F626A6563';
wwv_flow_imp.g_varchar2_table(22) := '742E6B65797328796F75724A534F4E4F626A656374292E6C656E6774682920627265616B3B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D0A202020207D0A0A2020202061776169742073656E';
wwv_flow_imp.g_varchar2_table(23) := '64426174636828293B202F2F205374617274207468652070726F636573730A7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(15492574191027630)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'plugin-ajax-processes.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2A0A202A20526563726561746573207468652048544D4C20656C656D656E74732066726F6D204A534F4E20646174612E0A202A0A202A2040706172616D207B626F6F6C65616E7D206564697461626C65202D20496E64696361746573207768657468';
wwv_flow_imp.g_varchar2_table(2) := '65722074686520656C656D656E74732073686F756C64206265206564697461626C652E0A202A2040706172616D207B737472696E677D20726567696F6E5F6964202D204964656E7469667920726567696F6E2E0A202A2F0A66756E6374696F6E20726563';
wwv_flow_imp.g_varchar2_table(3) := '726561746546726F6D4A736F6E286564697461626C652C20726567696F6E5F696429207B0A20202020636F6E736F6C652E6C6F672827726563726561746546726F6D4A736F6E27293B0A20202020726567696F6E5F6964203D20726567696F6E5F69642E';
wwv_flow_imp.g_varchar2_table(4) := '69643B0A202020202F2F4665746368696E672074686520646174612066726F6D20646976730A20202020766172206461746146726F6D44697673203D202428222E6A736F6E2D646174612D22202B20726567696F6E5F6964293B0A20202020636F6E736F';
wwv_flow_imp.g_varchar2_table(5) := '6C652E6C6F67282428222E6A736F6E2D646174612D22202B20726567696F6E5F6964292E6C656E677468293B0A20202020766172206A736F6E46726F6D44697673203D20227B223B0A20202020666F7220286C657420696E646578203D20303B20696E64';
wwv_flow_imp.g_varchar2_table(6) := '6578203C206461746146726F6D446976732E6C656E6774683B20696E6465782B2B29207B0A2020202020202020636F6E737420656C656D656E74203D206461746146726F6D446976735B696E6465785D3B0A20202020202020206A736F6E46726F6D4469';
wwv_flow_imp.g_varchar2_table(7) := '7673203D206A736F6E46726F6D44697673202B202428656C656D656E74292E6461746128226A736F6E22293B0A202020207D0A202020206A736F6E46726F6D44697673203D206A736F6E46726F6D44697673202B20277D273B0A202020206A736F6E4461';
wwv_flow_imp.g_varchar2_table(8) := '7461203D206A736F6E46726F6D446976733B0A202020202F2F20506172736520746865204A534F4E20737472696E6720746F20676574207468652064617461206F626A6563740A202020207661722064617461203D204A534F4E2E7061727365286A736F';
wwv_flow_imp.g_varchar2_table(9) := '6E44617461293B0A0A202020202F2F205265637265617465207468652064726F707061626C65207A6F6E652077697468207468652073617665642073697A6520616E6420706F736974696F6E0A2020202069662028216564697461626C6529207B0A2020';
wwv_flow_imp.g_varchar2_table(10) := '2020202020202F2F242827237772617070657227295B305D2E696E6E657248544D4C203D2022223B0A202020207D0A202020202F2F7661722064726F707061626C65446976203D206564697461626C65203F202428272364726F707061626C652729203A';
wwv_flow_imp.g_varchar2_table(11) := '202428273C6469762069643D2264726F707061626C65223E3C2F6469763E27293B0A202020207661722064726F707061626C65446976203D202428272364726F707061626C652E27202B20726567696F6E5F6964293B0A20202020747279207B0A202020';
wwv_flow_imp.g_varchar2_table(12) := '2020202020766172207769647468203D20284F626A6563742E6B6579732864617461292E6C656E677468203E203029203F20646174612E64726F707061626C652E7769647468203A20646F63756D656E742E676574456C656D656E744279496428227769';
wwv_flow_imp.g_varchar2_table(13) := '6E70757422292E76616C75653B0A202020202020202076617220686569676874203D20284F626A6563742E6B6579732864617461292E6C656E677468203E203029203F20646174612E64726F707061626C652E686569676874203A20646F63756D656E74';
wwv_flow_imp.g_varchar2_table(14) := '2E676574456C656D656E7442794964282268696E70757422292E76616C75653B0A2020202020202020696620286564697461626C6529207B0A20202020202020202020202064726F707061626C654469762E637373287B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(15) := '2020202077696474683A2077696474682C0A202020202020202020202020202020206865696768743A206865696768740A2020202020202020202020207D293B0A20202020202020207D20656C7365207B0A20202020202020202020202064726F707061';
wwv_flow_imp.g_varchar2_table(16) := '626C654469762E637373287B0A2020202020202020202020202020202077696474683A2077696474682C0A202020202020202020202020202020206865696768743A206865696768742C0A20202020202020202020202020202020706F736974696F6E3A';
wwv_flow_imp.g_varchar2_table(17) := '202772656C6174697665272C0A202020202020202020202020202020206261636B67726F756E64436F6C6F723A202723656565270A2020202020202020202020207D293B0A20202020202020207D0A202020207D206361746368202865727229207B0A20';
wwv_flow_imp.g_varchar2_table(18) := '20202020202020636F6E736F6C652E6C6F6728274E6F20696E7075747327293B0A202020207D0A0A202020202F2F2049746572617465206F76657220746865206469767320696E20746865204A534F4E206461746120616E642072656372656174652074';
wwv_flow_imp.g_varchar2_table(19) := '68656D0A20202020666F722028766172206B657920696E206461746129207B0A2020202020202020696620286B657920213D3D202764726F707061626C652729207B0A2020202020202020202020207661722064697644617461203D20646174615B6B65';
wwv_flow_imp.g_varchar2_table(20) := '795D3B0A20202020202020202020202076617220646976203D202428273C64697620636C6173733D2272656D6F7665222027202B2028646976446174612E617661696C61626C65203D3D3D20275927203F20276F6E436C69636B3D2227202B2064697644';
wwv_flow_imp.g_varchar2_table(21) := '6174612E6F6E436C69636B202B20272227203A20272729202B20273E3C2F6469763E27293B0A202020202020202020202020696620286564697461626C6529207B0A20202020202020202020202020202020646976203D202428273C64697620636C6173';
wwv_flow_imp.g_varchar2_table(22) := '733D2272656D6F7665222027202B20276F6E436C69636B3D2273656C65637428293B2227202B20273E3C2F6469763E27293B0A2020202020202020202020207D0A0A2020202020202020202020206469762E637373287B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '2020202077696474683A20646976446174612E77696474682C0A202020202020202020202020202020206865696768743A20646976446174612E6865696768742C0A20202020202020202020202020202020746F703A20646976446174612E746F702C0A';
wwv_flow_imp.g_varchar2_table(24) := '202020202020202020202020202020206C6566743A20646976446174612E6C6566742C0A20202020202020202020202020202020726F746174653A20646976446174612E726F746174652C0A20202020202020202020202020202020706F736974696F6E';
wwv_flow_imp.g_varchar2_table(25) := '3A20276162736F6C757465272F2F2C0A2020202020202020202020207D293B0A2020202020202020202020206469762E6174747228276964272C206B6579293B0A2020202020202020202020206469762E616464436C61737328646976446174612E636C';
wwv_flow_imp.g_varchar2_table(26) := '617373293B202F2F204164642074686520736176656420636C61737320746F2074686520726563726561746564206469760A2020202020202020202020202F2F2043726561746520616E20696E70757420656C656D656E742C2073657420746865207465';
wwv_flow_imp.g_varchar2_table(27) := '78742066726F6D20746865204A534F4E2C20616E642061646420617661696C6162696C69747920636C6173730A202020202020202020202020616464496E707574416E64417661696C6162696C697479436C617373286469762C2064697644617461293B';
wwv_flow_imp.g_varchar2_table(28) := '0A20202020202020202020202061646444697669636F6E7328646976293B0A20202020202020202020202064726F707061626C654469762E617070656E6428646976293B0A2020202020202020202020202F2F496E6E65722048544D4C20666F7220636F';
wwv_flow_imp.g_varchar2_table(29) := '6D706C69636174656420636F6D706F6E656E74730A20202020202020202020202069662028646976446174612E636C6173732E696E636C7564657328227061726B696E672D73706163652229207C7C20646976446174612E636C6173732E696E636C7564';
wwv_flow_imp.g_varchar2_table(30) := '657328227061726B696E672D73706163652D766572746963616C2229207C7C20646976446174612E636C6173732E696E636C7564657328226C6162656C222929207B0A0A2020202020202020202020207D20656C7365207B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(31) := '20202020207472797B0A20202020202020202020202020202020202020206469765B305D2E696E7365727441646A6163656E7448544D4C28276265666F7265656E64272C2028646976446174612E696E6E657248746D6C292E7265706C616365416C6C28';
wwv_flow_imp.g_varchar2_table(32) := '2740272C2027222729293B0A202020202020202020202020202020207D636174636828657272297B0A2020202020202020202020202020202020202020636F6E736F6C652E6C6F6728274E6F20696E6E65722068746D6C27293B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(33) := '202020202020207D0A2020202020202020202020207D0A20202020202020207D0A202020207D0A20202020696620286564697461626C6529207B0A20202020202020202F2F5265616374697661746520647261676761626C6520616E6420726573697A61';
wwv_flow_imp.g_varchar2_table(34) := '626C650A20202020202020202428222E72656D6F766522290A2020202020202020202020202E726573697A61626C65287B677269643A205B312C20315D7D290A2020202020202020202020202E647261676761626C65287B677269643A205B312C20315D';
wwv_flow_imp.g_varchar2_table(35) := '7D293B0A0A20202020202020206164644D6F62696C6546756E6374696F6E616C69747928290A202020207D20656C7365207B0A20202020202020202F2F20417070656E6420746865207265637265617465642064726F707061626C65207A6F6E6520746F';
wwv_flow_imp.g_varchar2_table(36) := '2074686520646F63756D656E7420626F6479206F7220616E79206465736972656420706172656E7420656C656D656E740A2020202020202020242827237772617070657227292E617070656E642864726F707061626C65446976293B0A202020207D0A20';
wwv_flow_imp.g_varchar2_table(37) := '2020202F2F46696C6C2073697A65206974656D7320776974682064726F707061626C652076616C7565730A20202020747279207B0A20202020202020207661722073656C656374456C656D656E74203D20646F63756D656E742E717565727953656C6563';
wwv_flow_imp.g_varchar2_table(38) := '746F7228222377696E70757422293B0A20202020202020207661722073656C656374456C656D656E7432203D20646F63756D656E742E717565727953656C6563746F7228222368696E70757422293B0A202020202020202073656C656374456C656D656E';
wwv_flow_imp.g_varchar2_table(39) := '742E76616C7565203D2077696474683B0A202020202020202073656C656374456C656D656E74322E76616C7565203D206865696768743B0A202020207D206361746368202865727229207B0A2020202020202020636F6E736F6C652E6C6F6728274E6F20';
wwv_flow_imp.g_varchar2_table(40) := '696E7075747327293B0A202020207D0A202020202428272E72656D6F766527292E62696E6428276472616773746F70272C2066756E6374696F6E202829207B2073656C656374287468697329207D293B0A7D0A2F2A2A0A202A20436F6E76657274732074';
wwv_flow_imp.g_varchar2_table(41) := '68652064617461206F6620726573697A61626C6520616E6420647261676761626C652064697620656C656D656E747320696E746F204A534F4E20666F726D61742E0A202A0A202A204072657475726E73207B737472696E677D20546865204A534F4E2073';
wwv_flow_imp.g_varchar2_table(42) := '7472696E6720726570726573656E746174696F6E206F662074686520646174612E0A202A2F0A66756E6374696F6E2073617665546F4A736F6E2829207B0A202020202F2F2043726561746520616E206F626A65637420746F2073746F7265207468652064';
wwv_flow_imp.g_varchar2_table(43) := '6174610A20202020766172206A736F6E44617461203D207B7D3B0A0A202020202F2F20476574207468652073697A6520616E6420706F736974696F6E206F66207468652064726F707061626C65206469760A202020207661722064726F707061626C6544';
wwv_flow_imp.g_varchar2_table(44) := '6976203D202428222364726F707061626C6522293B0A202020207661722064726F707061626C6544617461203D207B0A202020202020202077696474683A20242864726F707061626C65446976292E6373732822776964746822292C0A20202020202020';
wwv_flow_imp.g_varchar2_table(45) := '206865696768743A20242864726F707061626C65446976292E637373282268656967687422292C0A2020202020202020746F703A2027307078272C2F2F64726F707061626C654469762E6F666673657428292E746F702C0A20202020202020206C656674';
wwv_flow_imp.g_varchar2_table(46) := '3A2027307078272C2F2F64726F707061626C654469762E6F666673657428292E6C6566742C0A2020202020202020636C6173733A2064726F707061626C654469762E617474722827636C61737327292C0A202020202020202073706F7449643A2064726F';
wwv_flow_imp.g_varchar2_table(47) := '707061626C654469762E69640A202020207D3B0A202020206A736F6E446174615B2264726F707061626C65225D203D2064726F707061626C65446174613B0A0A202020202F2F2049746572617465206F766572206561636820726573697A61626C652061';
wwv_flow_imp.g_varchar2_table(48) := '6E6420647261676761626C65206469760A202020202428222E72656D6F766522292E656163682866756E6374696F6E202829207B0A2020202020202020766172206964203D20746869732E69643B0A20202020202020207661722064697644617461203D';
wwv_flow_imp.g_varchar2_table(49) := '207B0A20202020202020202020202077696474683A204D6174682E726F756E64287061727365466C6F617428242874686973292E6373732822776964746822292929202B20277078272C0A2020202020202020202020206865696768743A204D6174682E';
wwv_flow_imp.g_varchar2_table(50) := '726F756E64287061727365466C6F617428242874686973292E637373282268656967687422292929202B20277078272C0A202020202020202020202020746F703A204D6174682E726F756E64287061727365466C6F617428242874686973292E63737328';
wwv_flow_imp.g_varchar2_table(51) := '22746F7022292929202B20277078272C0A2020202020202020202020206C6566743A204D6174682E726F756E64287061727365466C6F617428242874686973292E63737328226C65667422292929202B20277078272C0A20202020202020202020202063';
wwv_flow_imp.g_varchar2_table(52) := '6C6173733A20242874686973292E617474722827636C61737327292C0A202020202020202020202020746578743A20242874686973292E66696E642827746578746172656127292E76616C28292C0A202020202020202020202020726F746174653A2024';
wwv_flow_imp.g_varchar2_table(53) := '2874686973292E6373732822726F7461746522292C0A20202020202020202020202073706F7449643A2069642C0A202020202020202020202020696E6E657248746D6C3A2028746869732E696E6E657248544D4C292E7265706C616365416C6C28272227';
wwv_flow_imp.g_varchar2_table(54) := '2C20274027292E7265706C616365282F285C725C6E7C5C6E7C5C72292F676D2C202222290A20202020202020207D3B0A20202020202020206A736F6E446174615B69645D203D20646976446174613B0A202020207D293B0A0A202020202F2F20436F6E76';
wwv_flow_imp.g_varchar2_table(55) := '65727420746865204A534F4E206F626A65637420746F206120737472696E670A20202020766172206A736F6E537472696E67203D204A534F4E2E737472696E67696679286A736F6E44617461293B0A202020202F2F636F6E736F6C652E6C6F67286A736F';
wwv_flow_imp.g_varchar2_table(56) := '6E537472696E67293B0A2020202072657475726E206A736F6E537472696E673B0A7D0A2F2A2A0A202A204368616E676573207468652073697A65206F66207468652064726F707061626C6520656C656D656E74206261736564206F6E2074686520696E70';
wwv_flow_imp.g_varchar2_table(57) := '75742076616C7565732E0A202A2F0A66756E6374696F6E206368616E676553697A652829207B0A202020207661722077203D20646F63756D656E742E676574456C656D656E7442794964282277696E70757422292E76616C75653B0A2020202076617220';
wwv_flow_imp.g_varchar2_table(58) := '68203D20646F63756D656E742E676574456C656D656E7442794964282268696E70757422292E76616C75653B0A0A202020207661722064617461203D205B0A20202020202020207B2057696474683A20772C204865696768743A2068207D0A202020205D';
wwv_flow_imp.g_varchar2_table(59) := '3B0A0A202020202428272364726F707061626C6527292E63737328277769647468272C2077293B0A202020202428272364726F707061626C6527292E6373732827686569676874272C2068293B0A7D0A2F2A2A0A202A2047656E65726174657320612072';
wwv_flow_imp.g_varchar2_table(60) := '616E646F6D20494420737472696E672E0A202A0A202A204072657475726E73207B737472696E677D205468652067656E65726174656420494420737472696E672E0A202A2F0A66756E6374696F6E206D616B6569642829207B0A2020202072657475726E';
wwv_flow_imp.g_varchar2_table(61) := '20276E65772D69642D27202B204D6174682E72616E646F6D28292E746F537472696E67283336292E73756273747228322C2039293B0A7D0A0A66756E6374696F6E2070726570617265456469746F722829207B0A202020207661722078203D206E756C6C';
wwv_flow_imp.g_varchar2_table(62) := '3B0A202020207661722074203D2027273B0A202020202F2F4D616B6520656C656D656E7420647261676761626C650A202020202428222E6472616722292E647261676761626C65287B0A202020202020202068656C7065723A2027636C6F6E65272C0A20';
wwv_flow_imp.g_varchar2_table(63) := '20202020202020637572736F723A20276D6F7665272C0A2020202020202020746F6C6572616E63653A2027666974272C0A20202020202020207265766572743A20747275652C0A2020202020202020677269643A205B312C20315D0A202020207D293B0A';
wwv_flow_imp.g_varchar2_table(64) := '0A202020202428222364726F707061626C6522292E64726F707061626C65287B0A20202020202020206163636570743A20272E64726167272C0A2020202020202020616374697665436C6173733A202264726F702D61726561222C0A2020202020202020';
wwv_flow_imp.g_varchar2_table(65) := '64726F703A2066756E6374696F6E2028652C20756929207B0A20202020202020202020202069662028242875692E647261676761626C65295B305D2E6964203D3D2022647261672229207B0A2020202020202020202020202020202078203D2075692E68';
wwv_flow_imp.g_varchar2_table(66) := '656C7065722E636C6F6E6528293B0A2020202020202020202020202020202075692E68656C7065722E72656D6F766528293B0A20202020202020202020202020202020782E647261676761626C65287B0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(67) := '2068656C7065723A20276F726967696E616C272C0A2020202020202020202020202020202020202020637572736F723A20276D6F7665272C0A20202020202020202020202020202020202020202F2F636F6E7461696E6D656E743A20272364726F707061';
wwv_flow_imp.g_varchar2_table(68) := '626C65272C0A2020202020202020202020202020202020202020746F6C6572616E63653A2027666974272C0A202020202020202020202020202020202020202064726F703A2066756E6374696F6E20286576656E742C20756929207B0A20202020202020';
wwv_flow_imp.g_varchar2_table(69) := '2020202020202020202020202020202020242875692E647261676761626C65292E72656D6F766528293B0A20202020202020202020202020202020202020207D2C0A2020202020202020202020202020202020202020647261673A2066756E6374696F6E';
wwv_flow_imp.g_varchar2_table(70) := '20286576656E742C20756929207B0A20202020202020202020202020202020202020202020202074203D2075692E706F736974696F6E3B0A20202020202020202020202020202020202020207D2C0A202020202020202020202020202020202020202067';
wwv_flow_imp.g_varchar2_table(71) := '7269643A205B312C20315D202F2F2041646A7573742074686520677269642073697A6520686572652028696E20706978656C73290A202020202020202020202020202020207D293B0A0A20202020202020202020202020202020782E726573697A61626C';
wwv_flow_imp.g_varchar2_table(72) := '65287B0A2020202020202020202020202020202020202020677269643A205B312C20315D0A202020202020202020202020202020207D293B0A20202020202020202020202020202020766172206E65774964203D206D616B65696428293B0A0A20202020';
wwv_flow_imp.g_varchar2_table(73) := '202020202020202020202020782E6174747228276964272C206E65774964293B0A20202020202020202020202020202020782E616464436C617373282772656D6F766527293B0A20202020202020202020202020202020782E72656D6F7665436C617373';
wwv_flow_imp.g_varchar2_table(74) := '28276472616727293B0A202020202020202020202020202020202F2F41646420696E70757420696E746F204449560A202020202020202020202020202020206966202828782E686173436C61737328227061726B696E672D73706163652229207C7C2028';
wwv_flow_imp.g_varchar2_table(75) := '782E686173436C61737328227061726B696E672D73706163652D766572746963616C222929292026262021782E66696E6428272E69642D696E70757427292E6C656E67746829207B0A202020202020202020202020202020202020202076617220696E70';
wwv_flow_imp.g_varchar2_table(76) := '7574203D202428273C746578746172656120747970653D22746578742220706C616365686F6C6465723D22456E74657220746578742220636C6173733D2269642D696E707574222F3E27293B0A2020202020202020202020202020202020202020782E61';
wwv_flow_imp.g_varchar2_table(77) := '7070656E6428696E707574293B0A202020202020202020202020202020207D0A0A20202020202020202020202020202020782E617070656E64546F28272364726F707061626C6527293B0A202020202020202020202020202020202428272E64656C6574';
wwv_flow_imp.g_varchar2_table(78) := '6527292E6F6E2827636C69636B272C2066756E6374696F6E202829207B0A2020202020202020202020202020202020202020242874686973292E706172656E7428292E706172656E7428277370616E27292E72656D6F766528293B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(79) := '20202020202020207D293B0A202020202020202020202020202020202428272E64656C65746527292E706172656E7428292E706172656E7428277370616E27292E64626C636C69636B2866756E6374696F6E202829207B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(80) := '2020202020202020242874686973292E72656D6F766528293B0A202020202020202020202020202020207D293B0A20202020202020202020202020202020766172206C6566744F6666736574203D204E756D62657228785B305D2E6F66667365744C6566';
wwv_flow_imp.g_varchar2_table(81) := '74293B0A2020202020202020202020202020202076617220746F704F6666736574203D204E756D62657228785B305D2E6F6666736574546F70293B0A0A20202020202020202020202020202020782E6373732827706F736974696F6E272C20276162736F';
wwv_flow_imp.g_varchar2_table(82) := '6C75746527293B0A202020202020202020202020202020202F2F43616C6962726174696F6E206F662064726F70206D617267696E730A2020202020202020202020202020202076617220706172656E744C6566744D617267696E203D20282428272E6472';
wwv_flow_imp.g_varchar2_table(83) := '6177696E672D706C7567696E2D626F647927292E706172656E7428292E63737328226D617267696E4C6566742229292E7265706C61636528277078272C202727293B0A2020202020202020202020202020202076617220656C656D656E74203D20242827';
wwv_flow_imp.g_varchar2_table(84) := '2E64726177696E672D706C7567696E2D626F647927292E706172656E7428293B0A202020202020202020202020202020207661722072656374203D202428656C656D656E74295B305D2E676574426F756E64696E67436C69656E745265637428293B0A20';
wwv_flow_imp.g_varchar2_table(85) := '20202020202020202020202020202076617220706172656E74546F704D617267696E203D20726563742E746F703B0A20202020202020202020202020202020766172206C6566744D617267696E56616C203D202428272E64726F70646F776E27292E6461';
wwv_flow_imp.g_varchar2_table(86) := '746128276C6566744D617267696E27293B0A2020202020202020202020202020202076617220746F704D617267696E56616C203D202428272E64726F70646F776E27292E646174612827746F704D617267696E27293B0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(87) := '202020782E63737328226C656674222C206C6566744F6666736574202D20706172656E744C6566744D617267696E202B206C6566744D617267696E56616C293B202F2F3131206973206C656674206D617267696E206F6620636F6D706F6E656E74202B20';
wwv_flow_imp.g_varchar2_table(88) := '626F72646572203170780A20202020202020202020202020202020782E6373732822746F70222C20746F704F6666736574202D20746F704D617267696E56616C293B202F2F39206973206D617267696E206F662064726F707A6F6E65202B20626F726465';
wwv_flow_imp.g_varchar2_table(89) := '7220312070780A20202020202020202020202020202020782E62696E6428276472616773746F70272C2066756E6374696F6E202829207B2073656C656374287468697329207D293B0A2020202020202020202020207D0A20202020202020207D0A202020';
wwv_flow_imp.g_varchar2_table(90) := '207D293B0A202020202428222372656D6F76652D6472616722292E64726F707061626C65287B0A202020202020202064726F703A2066756E6374696F6E20286576656E742C20756929207B0A202020202020202020202020242875692E64726167676162';
wwv_flow_imp.g_varchar2_table(91) := '6C65292E72656D6F766528293B0A20202020202020207D2C0A2020202020202020686F766572436C6173733A202272656D6F76652D647261672D686F766572222C0A20202020202020206163636570743A20272E72656D6F7665270A202020207D293B0A';
wwv_flow_imp.g_varchar2_table(92) := '20202020636F6E73742073656C656374456C656D656E74203D20646F63756D656E742E717565727953656C6563746F7228222377696E70757422293B0A20202020636F6E73742073656C656374456C656D656E7432203D20646F63756D656E742E717565';
wwv_flow_imp.g_varchar2_table(93) := '727953656C6563746F7228222368696E70757422293B0A20202020747279207B0A202020202020202073656C656374456C656D656E742E6164644576656E744C697374656E657228226368616E6765222C20286576656E7429203D3E207B0A2020202020';
wwv_flow_imp.g_varchar2_table(94) := '202020202020206368616E676553697A6528293B0A20202020202020207D293B0A202020202020202073656C656374456C656D656E74322E6164644576656E744C697374656E657228226368616E6765222C20286576656E7429203D3E207B0A20202020';
wwv_flow_imp.g_varchar2_table(95) := '20202020202020206368616E676553697A6528293B0A20202020202020207D293B0A202020207D206361746368202865727229207B0A0A202020207D0A0A202020202F2F6368616E676553697A6528293B0A7D0A0A2F2A2A0A202A20416464732069636F';
wwv_flow_imp.g_varchar2_table(96) := '6E7320746F2074686520676976656E20646976206261736564206F6E2069747320636C61737365732E0A202A0A202A2040706172616D207B6A51756572797D20646976202D20546865206A5175657279206F626A65637420726570726573656E74696E67';
wwv_flow_imp.g_varchar2_table(97) := '207468652064697620656C656D656E742E0A202A204072657475726E73207B6A51756572797D20546865206D6F646966696564206A5175657279206F626A65637420776974682061646465642069636F6E732E0A202A2F0A66756E6374696F6E20616464';
wwv_flow_imp.g_varchar2_table(98) := '44697669636F6E732864697629207B0A2020202076617220636C617373546F49636F6E203D207B0A2020202020202020276172726F772D6C656674273A202766612066612D6172726F772D6C656674272C0A2020202020202020276172726F772D726967';
wwv_flow_imp.g_varchar2_table(99) := '6874273A202766612066612D6172726F772D7269676874272C0A2020202020202020276172726F772D7570273A202766612066612D6172726F772D7570272C0A2020202020202020276172726F772D646F776E273A202766612066612D6172726F772D64';
wwv_flow_imp.g_varchar2_table(100) := '6F776E272C0A2020202020202020276172726F772D696E2D65617374273A202766612066612D626F782D6172726F772D696E2D65617374272C0A2020202020202020277061726B696E672D73706163652D70617261706C65676963273A20276661206661';
wwv_flow_imp.g_varchar2_table(101) := '2D776865656C6368616972270A20202020202020202F2F2041646420616E79206164646974696F6E616C206D617070696E677320686572650A202020207D3B0A0A202020206469762E656163682866756E6374696F6E202829207B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(102) := '666F72202876617220636C6173734E616D6520696E20636C617373546F49636F6E29207B0A20202020202020202020202069662028242874686973292E686173436C61737328636C6173734E616D652929207B0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(103) := '7661722069636F6E203D202428273C6920636C6173733D2227202B20636C617373546F49636F6E5B636C6173734E616D655D202B2027223E3C2F693E27293B0A20202020202020202020202020202020242874686973292E617070656E642869636F6E29';
wwv_flow_imp.g_varchar2_table(104) := '3B0A20202020202020202020202020202020627265616B3B0A2020202020202020202020207D0A20202020202020207D0A202020207D293B0A0A2020202072657475726E206469763B0A7D0A2F2A2A0A202A204164647320616E20696E70757420656C65';
wwv_flow_imp.g_varchar2_table(105) := '6D656E7420616E6420736574732074686520746578742066726F6D20746865204A534F4E20746F2074686520676976656E20656C656D656E742E0A202A20416C736F206164647320616E20617661696C6162696C69747920636C61737320626173656420';
wwv_flow_imp.g_varchar2_table(106) := '6F6E2074686520646976446174612E617661696C61626C652076616C75652E0A202A0A202A2040706172616D207B6A51756572797D20656C656D656E74202D20546865206A517565727920656C656D656E7420746F2077686963682074686520696E7075';
wwv_flow_imp.g_varchar2_table(107) := '7420656C656D656E7420616E6420636C6173732073686F756C642062652061646465642E0A202A2040706172616D207B4F626A6563747D2064697644617461202D20546865206469762064617461206F626A65637420636F6E7461696E696E6720746865';
wwv_flow_imp.g_varchar2_table(108) := '207465787420616E6420617661696C6162696C6974792076616C7565732E0A202A2F0A66756E6374696F6E20616464496E707574416E64417661696C6162696C697479436C61737328656C656D656E742C206469764461746129207B0A20202020696620';
wwv_flow_imp.g_varchar2_table(109) := '28656C656D656E742E686173436C61737328227061726B696E672D73706163652229207C7C20656C656D656E742E686173436C61737328227061726B696E672D73706163652D766572746963616C2229207C7C20656C656D656E742E686173436C617373';
wwv_flow_imp.g_varchar2_table(110) := '28226C6162656C222929207B0A202020202020202076617220696E707574203D202428273C746578746172656120747970653D22746578742220706C616365686F6C6465723D222220636C6173733D2269642D696E707574222F3E27293B0A2020202020';
wwv_flow_imp.g_varchar2_table(111) := '202020696E7075742E76616C28646976446174612E74657874293B0A2020202020202020656C656D656E742E617070656E6428696E707574293B0A0A20202020202020202F2F2044696374696F6E61727920666F7220617661696C6162696C6974792063';
wwv_flow_imp.g_varchar2_table(112) := '6C61737365730A202020202020202076617220617661696C6162696C697479436C6173736573203D207B0A2020202020202020202020202759273A2027617661696C61626C65272C0A202020202020202020202020274E273A20276E6F742D617661696C';
wwv_flow_imp.g_varchar2_table(113) := '61626C65272C0A2020202020202020202020202752273A20277265736572766564272C0A2020202020202020202020202F2F2041646420616E79206164646974696F6E616C206D617070696E677320686572650A20202020202020207D3B0A0A20202020';
wwv_flow_imp.g_varchar2_table(114) := '202020202F2F2041646420636C617373206261736564206F6E20617661696C6162696C6974790A202020202020202076617220617661696C6162696C697479436C617373203D20617661696C6162696C697479436C61737365735B646976446174612E61';
wwv_flow_imp.g_varchar2_table(115) := '7661696C61626C655D207C7C2027273B0A20202020202020206966202821656C656D656E742E686173436C61737328226C6162656C222929207B0A202020202020202020202020656C656D656E742E616464436C61737328617661696C6162696C697479';
wwv_flow_imp.g_varchar2_table(116) := '436C617373293B0A20202020202020207D0A202020207D0A7D0A0A2F2A2A0A202A20526F746174657320616E20656C656D656E7420627920612073706563696669656420616E676C6520696E20646567726565732E0A202A0A202A204066756E6374696F';
wwv_flow_imp.g_varchar2_table(117) := '6E0A202A2040706172616D207B737472696E677D2070695F6964202D20546865204944206F662074686520656C656D656E7420746F20626520726F74617465642E0A202A2040706172616D207B6E756D6265727D205B70695F76616C75653D31305D202D';
wwv_flow_imp.g_varchar2_table(118) := '2054686520616E676C6520696E206465677265657320627920776869636820746F20726F746174652074686520656C656D656E74202864656661756C742069732031302064656772656573292E0A202A204072657475726E73207B766F69647D0A202A2F';
wwv_flow_imp.g_varchar2_table(119) := '0A66756E6374696F6E20726F746174652870695F69642C2070695F76616C756529207B0A2020202076617220726F746174654279446567203D2070695F76616C7565207C7C2031303B0A202020207661722074686973456C656D656E74203D2024287069';
wwv_flow_imp.g_varchar2_table(120) := '5F6964292E706172656E7428293B0A202020207661722063757272656E74446567203D2074686973456C656D656E742E6373732822726F7461746522293B0A202020206966202863757272656E74446567203D3D20276E6F6E652729207B0A2020202020';
wwv_flow_imp.g_varchar2_table(121) := '20202074686973456C656D656E742E6373732822726F74617465222C20726F746174654279446567202B202264656722293B0A202020207D20656C7365207B0A202020202020202063757272656E74446567203D2063757272656E744465672E6D617463';
wwv_flow_imp.g_varchar2_table(122) := '68282F5C642B2F295B305D3B0A202020202020202063757272656E744465672E746F537472696E6728293B0A2020202020202020766172206E6577446567203D204E756D6265722863757272656E7444656729202B204E756D62657228726F7461746542';
wwv_flow_imp.g_varchar2_table(123) := '79446567293B0A202020202020202074686973456C656D656E742E6373732822726F74617465222C206E6577446567202B202264656722293B0A202020207D0A7D0A2F2A2A0A202A20536574732074686520696D61676520666F72206120737065636966';
wwv_flow_imp.g_varchar2_table(124) := '69632048544D4C20656C656D656E74206261736564206F6E207573657220696E7075742E0A202A2054686520696D6167652070617468206973207265747269657665642066726F6D20616E20696E707574206669656C6420776974682074686520696420';
wwv_flow_imp.g_varchar2_table(125) := '22696D6167652D70617468222E0A202A2054686520696D61676520697320736574206F6E206120646976207769746820746865206964202264726F707061626C65222E0A202A20546865206F706163697479206F662074686520696D6167652069732064';
wwv_flow_imp.g_varchar2_table(126) := '657465726D696E6564206279207468652076616C7565206F6620616E20696E707574206669656C642077697468207468652069642022696D6167652D6F706163697479222E0A202A2054686520626173652055524C20666F722074686520696D61676520';
wwv_flow_imp.g_varchar2_table(127) := '6973207265747269657665642066726F6D2061206461746120617474726962757465202822646174612D6170702D66696C65732D706174682229206F6E2074686520646976207769746820746865206964202264726F707061626C65222E0A202A204966';
wwv_flow_imp.g_varchar2_table(128) := '206120636865636B626F7820776974682074686520696420226261636B67726F756E642D7377697463682220697320636865636B65642C2074686520696D6167652069732073657420617320746865206261636B67726F756E6420696D616765206F6620';
wwv_flow_imp.g_varchar2_table(129) := '746865206469762E0A202A2049662074686520636865636B626F78206973206E6F7420636865636B65642C20616E79206578697374696E67206261636B67726F756E6420696D616765206F6E20746865206469762069732072656D6F7665642E0A202A2F';
wwv_flow_imp.g_varchar2_table(130) := '0A66756E6374696F6E20736574496D6167652829207B0A2020202076617220696D61676550617468203D20646F63756D656E742E676574456C656D656E74427949642822696D6167652D7061746822292E76616C75653B0A2020202076617220696D6167';
wwv_flow_imp.g_varchar2_table(131) := '65203D20646F63756D656E742E676574456C656D656E7442794964282264726F707061626C6522293B0A20202020766172206F706163697479203D2031202D20646F63756D656E742E676574456C656D656E74427949642822696D6167652D6F70616369';
wwv_flow_imp.g_varchar2_table(132) := '747922292E76616C75653B0A202020202F2F6765742074686520626173652075726C2066726F6D20646174612D6170702D66696C65732D706174682066726F6D2064697620776974682069642064726F707061626C650A20202020766172206261736575';
wwv_flow_imp.g_varchar2_table(133) := '726C203D20646F63756D656E742E676574456C656D656E7442794964282264726F707061626C6522292E6765744174747269627574652822646174612D6170702D66696C65732D7061746822293B0A202020202F2F696620636865636B626F7820776974';
wwv_flow_imp.g_varchar2_table(134) := '68206964206261636B67726F756E642D73776974636820697320636865636B65642C207365742074686520696D616765206173206261636B67726F756E6420696D616765206F662064697620776974682069642064726F707061626C650A202020206966';
wwv_flow_imp.g_varchar2_table(135) := '2028646F63756D656E742E676574456C656D656E744279496428226261636B67726F756E642D73776974636822292E636865636B656429207B0A2020202020202020696D6167652E7374796C652E6261636B67726F756E64496D616765203D20226C696E';
wwv_flow_imp.g_varchar2_table(136) := '6561722D6772616469656E74282072676261283235352C3235352C3235352C22202B206F706163697479202B2022292C2072676261283235352C3235352C3235352C22202B206F706163697479202B202229292C2075726C282722202B20626173657572';
wwv_flow_imp.g_varchar2_table(137) := '6C202B20696D61676550617468202B20222729223B0A2020202020202020696D6167652E7374796C652E6261636B67726F756E6453697A65203D2022313030252031303025223B0A202020207D20656C7365207B0A2020202020202020696D6167652E73';
wwv_flow_imp.g_varchar2_table(138) := '74796C652E6261636B67726F756E64496D616765203D2022223B0A2020202020202020696D6167652E7374796C652E6261636B67726F756E6453697A65203D2022223B0A202020207D0A7D0A0A2F2A2A0A202A2053656C65637473206F7220646573656C';
wwv_flow_imp.g_varchar2_table(139) := '6563747320616E20656C656D656E74206261736564206F6E206974732063757272656E742073746174652E0A202A0A202A204066756E6374696F6E0A202A2040706172616D207B48544D4C456C656D656E747D205B70695F656C656D656E745D202D2054';
wwv_flow_imp.g_varchar2_table(140) := '686520656C656D656E7420746F2062652073656C65637465642E204966206E6F742070726F76696465642C20746865206576656E74207461726765742077696C6C20626520757365642E0A202A204072657475726E73207B766F69647D0A202A2F0A6675';
wwv_flow_imp.g_varchar2_table(141) := '6E6374696F6E2073656C6563742870695F656C656D656E7429207B0A202020206966202870695F656C656D656E7429207B0A20202020202020207661722073656C6563746564456C656D656E74203D2070695F656C656D656E743B0A202020207D20656C';
wwv_flow_imp.g_varchar2_table(142) := '7365207B0A20202020202020207661722073656C6563746564456C656D656E74203D20746869732E6576656E742E7461726765743B0A202020207D0A202020206966202821242873656C6563746564456C656D656E74292E636C6F7365737428272E636F';
wwv_flow_imp.g_varchar2_table(143) := '6D706F6E656E74732D726F7727292E6C656E677468203E203029207B0A20202020202020206966202821242873656C6563746564456C656D656E74292E686173436C617373282775692D726573697A61626C652D68616E646C65272929207B0A20202020';
wwv_flow_imp.g_varchar2_table(144) := '20202020202020206966202821242873656C6563746564456C656D656E74292E686173436C6173732827636F6D706F6E656E7427292026262021242873656C6563746564456C656D656E74292E686173436C617373282769642D696E7075742729202626';
wwv_flow_imp.g_varchar2_table(145) := '2021242873656C6563746564456C656D656E74292E686173436C617373282769676E6F72652D73656C6563746564272929207B0A2020202020202020202020202020202073656C6563746564456C656D656E74203D20242873656C6563746564456C656D';
wwv_flow_imp.g_varchar2_table(146) := '656E74292E636C6F7365737428272E636F6D706F6E656E7427293B0A2020202020202020202020207D0A20202020202020202020202069662028242873656C6563746564456C656D656E74292E686173436C617373282773656C6563746564272929207B';
wwv_flow_imp.g_varchar2_table(147) := '0A20202020202020202020202020202020242873656C6563746564456C656D656E74292E72656D6F7665436C617373282773656C656374656427293B0A2020202020202020202020207D20656C73652069662028242873656C6563746564456C656D656E';
wwv_flow_imp.g_varchar2_table(148) := '74292E686173436C6173732827636F6D706F6E656E74272929207B0A20202020202020202020202020202020242873656C6563746564456C656D656E74292E616464436C617373282773656C656374656427293B0A2020202020202020202020207D2065';
wwv_flow_imp.g_varchar2_table(149) := '6C7365206966202821242873656C6563746564456C656D656E74292E686173436C6173732827636F6D706F6E656E74272929207B0A20202020202020202020202020202020242873656C6563746564456C656D656E74292E66696E6428272E636F6D706F';
wwv_flow_imp.g_varchar2_table(150) := '6E656E7427292E616464436C617373282773656C656374656427293B0A2020202020202020202020207D0A20202020202020207D0A202020207D0A7D0A0A2F2A2A0A202A20446573656C6563747320616C6C20656C656D656E7473207769746820746865';
wwv_flow_imp.g_varchar2_table(151) := '202773656C65637465642720636C6173732E0A202A204066756E6374696F6E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374696F6E20646573656C656374416C6C2829207B0A2020202076617220616C6C53656C656374656420';
wwv_flow_imp.g_varchar2_table(152) := '3D2041727261792E66726F6D282428272E73656C65637465642729293B0A20202020616C6C53656C65637465642E666F724561636828656C656D656E74203D3E207B0A20202020202020202428656C656D656E74292E72656D6F7665436C617373282773';
wwv_flow_imp.g_varchar2_table(153) := '656C656374656427293B0A202020207D293B0A7D0A0A2F2A2A0A202A20416C69676E73206469767320776974682074686520636C617373202273656C6563746564222065697468657220686F72697A6F6E74616C6C79206F7220766572746963616C6C79';
wwv_flow_imp.g_varchar2_table(154) := '206261736564206F6E207468652073706563696669656420617869732E0A202A2040706172616D207B737472696E677D2061786973202D20546865206178697320746F20616C69676E2074686520646976732E205573652022686F72697A6F6E74616C22';
wwv_flow_imp.g_varchar2_table(155) := '20666F7220686F72697A6F6E74616C20616C69676E6D656E7420616E642022766572746963616C2220666F7220766572746963616C20616C69676E6D656E742E0A202A2F0A66756E6374696F6E20616C69676E53656C6563746564446976732861786973';
wwv_flow_imp.g_varchar2_table(156) := '29207B0A20202020636F6E73742073656C656374656444697673203D20646F63756D656E742E717565727953656C6563746F72416C6C28272E73656C656374656427293B0A0A202020202F2F20436865636B2069662074686572652061726520616E7920';
wwv_flow_imp.g_varchar2_table(157) := '73656C656374656420646976732C206966206E6F742C2074686572652773206E6F7468696E6720746F20616C69676E2E0A202020206966202873656C6563746564446976732E6C656E677468203D3D3D203029207B0A202020202020202072657475726E';
wwv_flow_imp.g_varchar2_table(158) := '3B0A202020207D0A0A202020206966202861786973203D3D3D2027686F72697A6F6E74616C2729207B0A0A20202020202020206C657420746F74616C486F72697A6F6E74616C506F736974696F6E203D20303B0A0A20202020202020202F2F2043616C63';
wwv_flow_imp.g_varchar2_table(159) := '756C6174652074686520746F74616C20686F72697A6F6E74616C20706F736974696F6E2073756D206F6620616C6C2073656C656374656420646976732E0A2020202020202020666F722028636F6E737420646976206F662073656C656374656444697673';
wwv_flow_imp.g_varchar2_table(160) := '29207B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69656E745265637428293B0A202020202020202020202020746F74616C486F72697A6F6E74616C506F736974696F';
wwv_flow_imp.g_varchar2_table(161) := '6E202B3D20626F756E64696E67526563742E6C6566743B0A20202020202020207D0A0A2020202020202020636F6E73742061766572616765486F72697A6F6E74616C506F736974696F6E203D20746F74616C486F72697A6F6E74616C506F736974696F6E';
wwv_flow_imp.g_varchar2_table(162) := '202F2073656C6563746564446976732E6C656E6774683B0A0A20202020202020202F2F2041646A7573742074686520226C65667422204353532070726F7065727479206F6620656163682073656C65637465642064697620746F20616C69676E20746865';
wwv_flow_imp.g_varchar2_table(163) := '6D20686F72697A6F6E74616C6C792E0A2020202020202020666F722028636F6E737420646976206F662073656C65637465644469767329207B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F';
wwv_flow_imp.g_varchar2_table(164) := '756E64696E67436C69656E745265637428293B0A202020202020202020202020636F6E73742063757272656E744C656674203D20626F756E64696E67526563742E6C6566743B0A202020202020202020202020636F6E7374206F6666736574203D206176';
wwv_flow_imp.g_varchar2_table(165) := '6572616765486F72697A6F6E74616C506F736974696F6E202D2063757272656E744C6566743B0A2020202020202020202020206469762E7374796C652E6C656674203D2060247B63757272656E744C656674202B206F66667365747D7078603B0A202020';
wwv_flow_imp.g_varchar2_table(166) := '20202020207D0A202020207D20656C7365206966202861786973203D3D3D2027766572746963616C2729207B0A20202020202020206C657420746F74616C566572746963616C506F736974696F6E203D20303B0A0A20202020202020202F2F2043616C63';
wwv_flow_imp.g_varchar2_table(167) := '756C6174652074686520746F74616C20766572746963616C20706F736974696F6E2073756D206F6620616C6C2073656C656374656420646976732E0A2020202020202020666F722028636F6E737420646976206F662073656C6563746564446976732920';
wwv_flow_imp.g_varchar2_table(168) := '7B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69656E745265637428293B0A202020202020202020202020746F74616C566572746963616C506F736974696F6E202B3D';
wwv_flow_imp.g_varchar2_table(169) := '20626F756E64696E67526563742E746F703B0A20202020202020207D0A0A2020202020202020636F6E73742061766572616765566572746963616C506F736974696F6E203D20746F74616C566572746963616C506F736974696F6E202F2073656C656374';
wwv_flow_imp.g_varchar2_table(170) := '6564446976732E6C656E6774683B0A0A20202020202020202F2F2041646A757374207468652022746F7022204353532070726F7065727479206F6620656163682073656C65637465642064697620746F20616C69676E207468656D20766572746963616C';
wwv_flow_imp.g_varchar2_table(171) := '6C792E0A2020202020202020666F722028636F6E737420646976206F662073656C65637465644469767329207B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69656E74';
wwv_flow_imp.g_varchar2_table(172) := '5265637428293B0A202020202020202020202020636F6E73742063757272656E74546F70203D20626F756E64696E67526563742E746F703B0A202020202020202020202020636F6E7374206F6666736574203D2061766572616765566572746963616C50';
wwv_flow_imp.g_varchar2_table(173) := '6F736974696F6E202D2063757272656E74546F703B0A2020202020202020202020206469762E7374796C652E746F70203D2060247B63757272656E74546F70202B206F66667365747D7078603B0A20202020202020207D0A202020207D20656C7365207B';
wwv_flow_imp.g_varchar2_table(174) := '0A2020202020202020636F6E736F6C652E6572726F722827496E76616C6964206178697320706172616D657465722E20506C65617365207573652022686F72697A6F6E74616C22206F722022766572746963616C222E27293B0A202020207D0A7D0A0A2F';
wwv_flow_imp.g_varchar2_table(175) := '2A2A0A202A20436C6F6E657320616C6C2073656C65637465642064697620656C656D656E747320616E6420617070656E6473207468656D20746F2074686520646976207769746820746865206964202264726F707061626C65222E0A202A204561636820';
wwv_flow_imp.g_varchar2_table(176) := '636C6F6E656420646976206973206D61646520647261676761626C6520616E6420697320676976656E2061206E657720756E697175652069642E0A202A20546865202273656C65637465642220636C61737320697320616464656420746F206561636820';
wwv_flow_imp.g_varchar2_table(177) := '636C6F6E6564206469762E0A202A20416674657220636C6F6E696E672C20616C6C206F726967696E616C20646976732061726520646573656C65637465642E0A202A2054686520636C6F6E656420646976732061726520696E7365727465642072696768';
wwv_flow_imp.g_varchar2_table(178) := '7420616674657220746865206F726967696E616C20646976732E0A202A204120276472616773746F7027206576656E7420697320626F756E6420746F206561636820636C6F6E6564206469762C2077686963682063616C6C7320746865202773656C6563';
wwv_flow_imp.g_varchar2_table(179) := '74272066756E6374696F6E207768656E207468652064697620697320646F6E65206265696E6720647261676765642E0A202A2F0A66756E6374696F6E20636F7079416E6450617374654469762829207B0A2020202076617220616C6C53656C6563746564';
wwv_flow_imp.g_varchar2_table(180) := '203D2041727261792E66726F6D282428272E73656C65637465642729293B0A20202020646573656C656374416C6C28293B0A20202020616C6C53656C65637465642E666F724561636828656C656D656E74203D3E207B0A20202020202020202F2F20436C';
wwv_flow_imp.g_varchar2_table(181) := '6F6E6520746865206F726967696E616C204449560A2020202020202020636F6E7374206E6577446976203D20656C656D656E742E636C6F6E654E6F64652874727565293B0A0A20202020202020202F2F2041646420746865202273656C65637465642220';
wwv_flow_imp.g_varchar2_table(182) := '636C61737320746F20746865206E6577204449560A20202020202020206E65774469762E636C6173734C6973742E616464282773656C656374656427293B0A2020202020202020766172206E65774964203D206D616B65696428293B0A20202020202020';
wwv_flow_imp.g_varchar2_table(183) := '206E65774469762E6964203D206E657749643B0A0A20202020202020202F2F20496E7365727420746865206E65772044495620726967687420616674657220746865206F726967696E616C204449560A20202020202020202428272364726F707061626C';
wwv_flow_imp.g_varchar2_table(184) := '6527292E617070656E64286E6577446976293B0A202020202020202024286E6577446976292E647261676761626C65287B677269643A205B312C20315D7D293B0A202020202020202024286E6577446976292E62696E6428276472616773746F70272C20';
wwv_flow_imp.g_varchar2_table(185) := '66756E6374696F6E202829207B2073656C656374287468697329207D293B0A202020207D293B0A0A7D0A0A66756E6374696F6E2064656C65746553656C65637465642829207B0A202020202428272E73656C656374656427292E72656D6F766528293B0A';
wwv_flow_imp.g_varchar2_table(186) := '7D0A0A66756E6374696F6E20726F7461746553656C65637465642829207B0A2020202076617220616C6C53656C6563746564203D202428272E73656C656374656427293B0A20202020666F7220286C657420696E646578203D20303B20696E646578203C';
wwv_flow_imp.g_varchar2_table(187) := '20616C6C53656C65637465642E6C656E6774683B20696E6465782B2B29207B0A2020202020202020636F6E737420656C656D656E74203D20616C6C53656C65637465645B696E6465785D3B0A202020202020202076617220726F74617465427944656720';
wwv_flow_imp.g_varchar2_table(188) := '3D2034353B0A20202020202020207661722063757272656E74446567203D202428656C656D656E74292E6373732822726F7461746522293B0A20202020202020206966202863757272656E74446567203D3D20273336306465672729207B0A2020202020';
wwv_flow_imp.g_varchar2_table(189) := '2020202020202063757272656E74446567203D20276E6F6E65273B0A20202020202020207D0A20202020202020206966202863757272656E74446567203D3D20276E6F6E652729207B0A2020202020202020202020202428656C656D656E74292E637373';
wwv_flow_imp.g_varchar2_table(190) := '2822726F74617465222C20726F746174654279446567202B202264656722293B0A20202020202020207D20656C7365207B0A20202020202020202020202063757272656E74446567203D2063757272656E744465672E6D61746368282F5C642B2F295B30';
wwv_flow_imp.g_varchar2_table(191) := '5D3B0A20202020202020202020202063757272656E744465672E746F537472696E6728293B0A202020202020202020202020766172206E6577446567203D204E756D6265722863757272656E7444656729202B204E756D62657228726F74617465427944';
wwv_flow_imp.g_varchar2_table(192) := '6567293B0A2020202020202020202020202428656C656D656E74292E6373732822726F74617465222C206E6577446567202B202264656722293B0A20202020202020207D0A202020207D0A0A7D0A70726570617265456469746F7228293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(15492869007027635)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'map.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2A0A202A205377697463686573207468652061637469766520636F6D706F6E656E74207479706520616E6420646973706C6179732074686520636F72726573706F6E64696E6720636F6D706F6E656E747320726F772E0A202A0A202A204066756E63';
wwv_flow_imp.g_varchar2_table(2) := '74696F6E0A202A2040706172616D207B737472696E677D206964202D20546865204944206F662074686520636F6D706F6E656E74207479706520746F2073776974636820746F2E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374';
wwv_flow_imp.g_varchar2_table(3) := '696F6E207377697463685479706528696429207B0A202020202F2F2050726570617265207468652073656C6563746F7220666F72207468652074617267657420636F6D706F6E656E747320726F770A202020207661722069645072657061726564203D20';
wwv_flow_imp.g_varchar2_table(4) := '6064697623247B69647D2E636F6D706F6E656E74732D726F77603B0A2020202076617220636F6D706F6E656E7473526F77203D20242869645072657061726564293B0A0A202020202F2F20546F67676C65207669736962696C697479206F6620616C6C20';
wwv_flow_imp.g_varchar2_table(5) := '636F6D706F6E656E747320726F77732C20686964696E67206F74686572730A202020202428272E636F6D706F6E656E74732D726F7727292E6869646528293B0A20202020636F6D706F6E656E7473526F772E73686F7728293B0A0A202020202F2F20546F';
wwv_flow_imp.g_varchar2_table(6) := '67676C652074686520616374697665207374617465206F66207479706520627574746F6E730A2020202076617220627574746F6E436C69636B6564203D20606C6923247B69647D603B0A202020202428276C692E742D546162732D6974656D27292E7265';
wwv_flow_imp.g_varchar2_table(7) := '6D6F7665436C6173732827612D546162732D73656C656374656427293B0A202020202428276C692E742D546162732D6974656D27292E72656D6F7665436C617373282769732D61637469766527293B0A202020202428627574746F6E436C69636B656429';
wwv_flow_imp.g_varchar2_table(8) := '2E616464436C6173732827612D546162732D73656C656374656427293B0A202020202428627574746F6E436C69636B6564292E616464436C617373282769732D61637469766527293B0A7D0A0A2F2A2A0A202A20546F67676C6573207468652067726964';
wwv_flow_imp.g_varchar2_table(9) := '206261636B67726F756E64206F6E20746865202764726F707061626C652720656C656D656E742E0A202A0A202A204066756E6374696F6E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374696F6E2073686F77477269642829207B';
wwv_flow_imp.g_varchar2_table(10) := '0A202020202F2F20436865636B20696620746865202764726F707061626C652720656C656D656E7420686173207468652027677269642D6261636B67726F756E642720636C6173730A20202020696620282428272364726F707061626C6527292E686173';
wwv_flow_imp.g_varchar2_table(11) := '436C6173732827677269642D6261636B67726F756E64272929207B0A20202020202020202F2F204966206974206861732074686520636C6173732C2072656D6F766520697420746F2068696465207468652067726964206261636B67726F756E640A2020';
wwv_flow_imp.g_varchar2_table(12) := '2020202020202428272364726F707061626C6527292E72656D6F7665436C6173732827677269642D6261636B67726F756E6427293B0A202020207D20656C7365207B0A20202020202020202F2F20496620697420646F65736E2774206861766520746865';
wwv_flow_imp.g_varchar2_table(13) := '20636C6173732C2061646420697420746F2073686F77207468652067726964206261636B67726F756E640A20202020202020202428272364726F707061626C6527292E616464436C6173732827677269642D6261636B67726F756E6427293B0A20202020';
wwv_flow_imp.g_varchar2_table(14) := '7D0A7D0A0A2F2A2A0A202A20546F67676C657320746865207669736962696C697479206F6620746865206D61702073657474696E67732064726F70646F776E206D656E752E0A202A0A202A204066756E6374696F6E0A202A204072657475726E73207B76';
wwv_flow_imp.g_varchar2_table(15) := '6F69647D0A202A2F0A66756E6374696F6E20746F67676C654D617053657474696E67732829207B0A202020202F2F20546F67676C6520746865202273686F772220636C617373206F6E2074686520226D617053657474696E677344726F70646F776E2220';
wwv_flow_imp.g_varchar2_table(16) := '656C656D656E7420746F20636F6E74726F6C207669736962696C6974790A20202020646F63756D656E742E676574456C656D656E744279496428226D617053657474696E677344726F70646F776E22292E636C6173734C6973742E746F67676C65282273';
wwv_flow_imp.g_varchar2_table(17) := '686F7722293B0A7D0A0A766172207A6F6F6D5363616C65203D20313B0A2F2A2A0A202A205365747320746865207A6F6F6D206C6576656C206F6620616E20656C656D656E742E0A202A0A202A2040706172616D207B6E756D6265727D207A6F6F6D202D20';
wwv_flow_imp.g_varchar2_table(18) := '546865207A6F6F6D206C6576656C20746F207365742E0A202A2040706172616D207B48544D4C456C656D656E747D20656C202D2054686520656C656D656E7420746F206170706C7920746865207A6F6F6D20746F2E204966206E6F742070726F76696465';
wwv_flow_imp.g_varchar2_table(19) := '642C2074686520636F6E7461696E657220656C656D656E742077696C6C20626520757365642E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374696F6E207365745A6F6F6D287A6F6F6D2C20656C29207B0A202020207472616E73';
wwv_flow_imp.g_varchar2_table(20) := '666F726D4F726967696E203D205B302C20305D3B0A202020207661722070203D205B227765626B6974222C20226D6F7A222C20226D73222C20226F225D2C0A202020202020202073203D20227363616C652822202B207A6F6F6D202B202229222C0A2020';
wwv_flow_imp.g_varchar2_table(21) := '2020202020206F537472696E67203D20287472616E73666F726D4F726967696E5B305D202A2031303029202B2022252022202B20287472616E73666F726D4F726967696E5B315D202A2031303029202B202225223B0A20202020666F7220287661722069';
wwv_flow_imp.g_varchar2_table(22) := '203D20303B2069203C20702E6C656E6774683B20692B2B29207B0A2020202020202020656C2E7374796C655B705B695D202B20225472616E73666F726D225D203D20733B0A2020202020202020656C2E7374796C655B705B695D202B20225472616E7366';
wwv_flow_imp.g_varchar2_table(23) := '6F726D4F726967696E225D203D206F537472696E673B0A202020207D0A20202020656C2E7374796C655B227472616E73666F726D225D203D20733B0A20202020656C2E7374796C655B227472616E73666F726D4F726967696E225D203D206F537472696E';
wwv_flow_imp.g_varchar2_table(24) := '673B0A7D0A2F2A2A0A202A205570646174657320746865207A6F6F6D207363616C6520616E64206170706C69657320746865207A6F6F6D20746F207468652073706563696669656420656C656D656E742E0A202A0A202A2040706172616D207B6E756D62';
wwv_flow_imp.g_varchar2_table(25) := '65727D2061202D205468652076616C756520746F20696E6372656D656E7420746865207A6F6F6D207363616C652062792E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374696F6E2073686F7756616C286129207B0A2020202076';
wwv_flow_imp.g_varchar2_table(26) := '6172206D696E446966666572656E6365203D20303B0A202020207472797B0A20202020202020206966202861203D3D20276D617827297B0A202020202020202020202020766172207A6F6F6D436F6E7461696E657253697A65203D205B5D3B0A20202020';
wwv_flow_imp.g_varchar2_table(27) := '2020202020202020766172207A6F6F6D436F6E7461696E6572203D20646F63756D656E742E717565727953656C6563746F7228272E7A6F6F6D2D6164646974696F6E616C2D636F6E7461696E657227293B0A202020202020202020202020696620287A6F';
wwv_flow_imp.g_varchar2_table(28) := '6F6D436F6E7461696E657229207B0A202020202020202020202020202020207A6F6F6D436F6E7461696E657253697A65203D205B7A6F6F6D436F6E7461696E65722E6F666673657457696474682C207A6F6F6D436F6E7461696E65722E6F666673657448';
wwv_flow_imp.g_varchar2_table(29) := '65696768745D3B0A2020202020202020202020207D0A20202020202020202020202076617220626F647953697A65203D205B5D3B0A20202020202020202020202076617220626F6479436F6E7461696E6572203D20646F63756D656E742E717565727953';
wwv_flow_imp.g_varchar2_table(30) := '656C6563746F7228272E64726F7061626C652D7A6F6E652D626F647927293B0A20202020202020202020202069662028626F6479436F6E7461696E657229207B0A20202020202020202020202020202020626F647953697A65203D205B626F6479436F6E';
wwv_flow_imp.g_varchar2_table(31) := '7461696E65722E6F666673657457696474682C20626F6479436F6E7461696E65722E6F66667365744865696768745D3B0A2020202020202020202020207D0A2020202020202020202020202F2F66696E64206D696E756D756D20646966666572656E6365';
wwv_flow_imp.g_varchar2_table(32) := '206265747765656E207A6F6F6D436F6E7461696E657253697A6520616E6420626F647953697A650A2020202020202020202020206D696E446966666572656E6365203D204D6174682E6D696E284D6174682E616273287A6F6F6D436F6E7461696E657253';
wwv_flow_imp.g_varchar2_table(33) := '697A655B305D202F20626F647953697A655B305D292C204D6174682E616273287A6F6F6D436F6E7461696E657253697A655B315D202F20626F647953697A655B315D29293B0A20202020202020207D0A202020207D636174636828657272297B0A202020';
wwv_flow_imp.g_varchar2_table(34) := '2020202020636F6E736F6C652E6C6F6728657272293B0A202020207D0A202020206966286D696E446966666572656E636520213D3D2030297B0A20202020202020207A6F6F6D5363616C65203D206D696E446966666572656E63653B0A202020207D656C';
wwv_flow_imp.g_varchar2_table(35) := '73657B0A20202020202020207A6F6F6D5363616C65203D207A6F6F6D5363616C65202B204E756D6265722861293B0A202020207D0A202020207365745A6F6F6D287A6F6F6D5363616C652C20646F63756D656E742E676574456C656D656E74734279436C';
wwv_flow_imp.g_varchar2_table(36) := '6173734E616D65282764726F7061626C652D7A6F6E652D626F647927295B305D290A202020202F2F7365745A6F6F6D287A6F6F6D5363616C652C20646F63756D656E742E676574456C656D656E74734279436C6173734E616D652827636F6D706F6E656E';
wwv_flow_imp.g_varchar2_table(37) := '7427295B305D290A7D0A2F2F416464696E67206C697374656E657220666F7220646573656C656374416C6C207768656E20636C69636B6564206F6E20746865206261636B67726F756E640A646F63756D656E742E717565727953656C6563746F72416C6C';
wwv_flow_imp.g_varchar2_table(38) := '28272E64726F7061626C652D7A6F6E652D626F647927292E666F724561636828646976203D3E207B0A202020206469762E6164644576656E744C697374656E65722827636C69636B272C2066756E6374696F6E286576656E7429207B0A20202020202020';
wwv_flow_imp.g_varchar2_table(39) := '202F2F20436865636B2069662074686520636C69636B656420656C656D656E74206973207468652064697620697473656C6620616E64206E6F742061206368696C6420656C656D656E740A2020202020202020696620286576656E742E74617267657420';
wwv_flow_imp.g_varchar2_table(40) := '3D3D3D207468697329207B0A202020202020202020202020646573656C656374416C6C28293B0A20202020202020207D0A202020207D293B0A7D293B0A73686F774772696428293B0A737769746368547970652831293B0A73686F7756616C2830293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(15493249811027649)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'control-functions.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E66612D706C75732D737175617265207B0A20202020636F6C6F723A20677265656E3B0A7D0A0A2E742D427574746F6E526567696F6E2D636F6C2D2D636F6E74656E74207B0A20202020646973706C61793A20666C65783B0A7D0A0A6C69207B0A202020';
wwv_flow_imp.g_varchar2_table(2) := '206C6973742D7374796C652D747970653A206E6F6E653B0A7D0A0A2E6C69207B0A202020206D617267696E2D746F703A20313270783B0A202020206D617267696E2D626F74746F6D3A203570783B0A7D0A0A756C206C69207B0A202020206C6973742D73';
wwv_flow_imp.g_varchar2_table(3) := '74796C653A206E6F6E653B0A7D0A0A2E647261672D6C69737420696D67207B0A2020202077696474683A20383070783B0A202020206865696768743A20383070783B0A20202020766572746963616C2D616C69676E3A206D6964646C653B0A2020202063';
wwv_flow_imp.g_varchar2_table(4) := '7572736F723A206D6F76653B0A7D0A0A2E647261672D6C69737420756C207B0A202020206D617267696E3A20303B0A2020202070616464696E673A20303B0A7D0A0A2E647261672D6C697374206C69207B0A202020206D617267696E2D626F74746F6D3A';
wwv_flow_imp.g_varchar2_table(5) := '203570783B0A7D0A0A6C692E686F72697A6F6E74616C207B0A2020202070616464696E673A203570782030707820357078203070783B0A202020206865696768743A20353070783B0A202020206C6973742D7374796C652D747970653A206E6F6E653B0A';
wwv_flow_imp.g_varchar2_table(6) := '7D0A0A2E736570617261746F72207B0A2020202077696474683A20313070783B0A202020206865696768743A20353070783B0A20202020666C6F61743A206C6566743B0A7D0A0A0A2E6E6F742D73656C65637461626C65207B0A20202020706F696E7465';
wwv_flow_imp.g_varchar2_table(7) := '722D6576656E74733A206E6F6E653B0A7D0A0A2E73656C6563742D74797065207B0A2020202077696474683A206175746F3B0A2020202070616464696E673A20313070783B0A202020206D617267696E2D72696768743A20313070783B0A20202020626F';
wwv_flow_imp.g_varchar2_table(8) := '726465723A2031707820736F6C696420726762283231332C203231332C20323133293B0A202020206261636B67726F756E642D636F6C6F723A2077686974653B0A20202020626F726465722D7261646975733A203570783B0A20202020666C6F61743A20';
wwv_flow_imp.g_varchar2_table(9) := '6C6566743B0A7D0A0A2E747970652D73656C6563742D73656374696F6E207B0A202020202F2A646973706C61793A20666C65783B2A2F0A202020206D617267696E2D626F74746F6D3A20313070783B0A7D0A0A2364726F707061626C65207B0A20202020';
wwv_flow_imp.g_varchar2_table(10) := '77696474683A2035353070783B0A202020206865696768743A2035343070783B0A20202020626F726465723A2031707820736F6C696420626C61636B3B0A0A7D0A0A2E677269642D6261636B67726F756E64207B0A202020202D2D733A2031303070783B';
wwv_flow_imp.g_varchar2_table(11) := '0A202020202F2A20636F6E74726F6C207468652073697A65202A2F0A202020202D2D5F673A2023303030302039306465672C20726762283230392C203233342C203234352920303B0A202020206261636B67726F756E643A0A2020202020202020636F6E';
wwv_flow_imp.g_varchar2_table(12) := '69632D6772616469656E742866726F6D20393064656720617420327078203270782C20766172282D2D5F672929203020302F766172282D2D732920766172282D2D73292C0A2020202020202020636F6E69632D6772616469656E742866726F6D20393064';
wwv_flow_imp.g_varchar2_table(13) := '656720617420317078203170782C20766172282D2D5F672929203020302F63616C6328766172282D2D73292F35292063616C6328766172282D2D73292F35293B0A7D0A0A2E7269676874207B0A20202020666C6F61743A2072696768743B0A7D0A0A2E6C';
wwv_flow_imp.g_varchar2_table(14) := '656674207B0A20202020666C6F61743A206C6566743B0A7D0A0A2E636C656172207B0A20202020636C6561723A20626F74683B0A7D0A0A0A2E72656D6F76652D647261672D686F766572207B0A202020206261636B67726F756E642D636F6C6F723A2023';
wwv_flow_imp.g_varchar2_table(15) := '6564343934392021696D706F7274616E743B0A7D0A0A2E64726167207B0A20202020726573697A653A20626F74683B0A202020206F766572666C6F773A206175746F3B0A7D0A0A2E69642D696E707574207B0A20202020746578742D616C69676E3A2072';
wwv_flow_imp.g_varchar2_table(16) := '696768743B0A2020202077696474683A2063616C632831303025202D2031307078293B0A202020206261636B67726F756E642D636F6C6F723A206C69676874626C75653B0A20202020626F726465723A20302E35707820736F6C696420677261793B0A7D';
wwv_flow_imp.g_varchar2_table(17) := '0A0A2E72656D6F7665207B0A202020206F766572666C6F773A2068696464656E3B0A7D0A2E627574746F6E2D64726F70646F776E2D6D61707B0A202020206D617267696E2D72696768743A203570782021696D706F7274616E743B0A7D0A0A2E64726F70';
wwv_flow_imp.g_varchar2_table(18) := '646F776E207B0A20202020706F736974696F6E3A2072656C61746976653B0A20202020646973706C61793A20696E6C696E652D626C6F636B3B0A20207D0A20200A20202E64726F70646F776E2D636F6E74656E74207B0A20202020646973706C61793A20';
wwv_flow_imp.g_varchar2_table(19) := '6E6F6E653B0A20202020706F736974696F6E3A206162736F6C7574653B0A202020206261636B67726F756E642D636F6C6F723A20236631663166313B0A202020206D696E2D77696474683A2032303070783B0A202020206F766572666C6F773A20617574';
wwv_flow_imp.g_varchar2_table(20) := '6F3B0A20202020626F782D736861646F773A2030707820387078203136707820307078207267626128302C302C302C302E32293B0A202020207A2D696E6465783A20313B0A20207D0A20202E64726F70646F776E2D696E6E65727B0A2020202020207061';
wwv_flow_imp.g_varchar2_table(21) := '6464696E673A20323070783B0A20207D0A20202E64726F70646F776E2D696E6E65723E627574746F6E7B0A2020202077696474683A20313030253B0A20207D0A20200A20202E73686F77207B646973706C61793A20626C6F636B3B7D0A20202E73697A65';
wwv_flow_imp.g_varchar2_table(22) := '2D696E7075747B0A202020206D617267696E2D626F74746F6D3A203570783B0A20207D0A2020756C2E637573746F6D2D746162737B0A202020206D617267696E2D626F74746F6D3A203470783B0A20207D0A0A20202E766572746963616C207B0A202020';
wwv_flow_imp.g_varchar2_table(23) := '20726F746174653A2039306465673B0A7D0A0A2373697A652D73657474696E6773207B0A202020206D617267696E3A20313070783B0A7D0A0A2E636F6D706F6E656E74207B0A202020206D617267696E3A20313070783B0A7D0A0A2E636F6D706F6E656E';
wwv_flow_imp.g_varchar2_table(24) := '74732D726F77207B0A20202020646973706C61793A20666C65783B0A2020202077696474683A20313030253B0A20202020626F726465723A2031707820736F6C696420726762283231332C203231332C20323133293B0A20202020626F726465722D7261';
wwv_flow_imp.g_varchar2_table(25) := '646975733A203570783B0A20202020666C65782D646972656374696F6E3A20726F773B0A20202020666C65782D777261703A20777261703B0A7D0A0A2E73656C6563742D74797065207B0A2020202077696474683A206175746F3B0A2020202070616464';
wwv_flow_imp.g_varchar2_table(26) := '696E673A20313070783B0A202020206D617267696E2D72696768743A20313070783B0A20202020626F726465723A2031707820736F6C696420726762283231332C203231332C20323133293B0A202020206261636B67726F756E642D636F6C6F723A2077';
wwv_flow_imp.g_varchar2_table(27) := '686974653B0A20202020626F726465722D7261646975733A203570783B0A20202020666C6F61743A206C6566743B0A7D0A0A2E747970652D73656C6563742D73656374696F6E207B0A20202020646973706C61793A20666C65783B0A20202020666C6578';
wwv_flow_imp.g_varchar2_table(28) := '2D646972656374696F6E3A20726F773B0A20202020666C65782D777261703A20777261703B0A7D0A0A0A2E73656C6563742D747970652E616374697665207B0A202020206261636B67726F756E642D636F6C6F723A207267622839342C203139312C2032';
wwv_flow_imp.g_varchar2_table(29) := '3535293B0A7D0A0A2E75692D64726F707061626C652D616374697665207B0A202020206261636B67726F756E642D636F6C6F723A207472616E73706172656E742021696D706F7274616E743B0A7D0A0A2E677269642D6C656674207B0A202020206D6178';
wwv_flow_imp.g_varchar2_table(30) := '2D77696474683A203730253B0A20202020666C6F61743A206C6566743B0A7D0A0A2E677269642D7269676874207B0A202020206D696E2D77696474683A203330253B0A20202020666C6F61743A206C6566743B0A202020206D617267696E2D6C6566743A';
wwv_flow_imp.g_varchar2_table(31) := '20313270783B0A202020206D617267696E2D746F703A20343570783B0A7D0A0A2E73656C6563746564207B0A202020206F75746C696E653A20746869636B20736F6C6964206C69676874677265656E3B0A7D0A0A2E696E70757473207B0A202020207769';
wwv_flow_imp.g_varchar2_table(32) := '6474683A20373070783B0A7D0A0A2E6C6566742D736964652D627574746F6E73207B0A20202020646973706C61793A20666C65783B0A20202020666C65782D646972656374696F6E3A20726F773B0A7D0A0A2E64726177696E672D706C7567696E2D626F';
wwv_flow_imp.g_varchar2_table(33) := '6479207B0A20202020646973706C61793A20666C65783B0A20202020666C65782D646972656374696F6E3A20726F773B0A7D0A0A2E64726F707061626C652D7363726F6C6C2D706172656E74207B0A202020206F766572666C6F772D793A206175746F3B';
wwv_flow_imp.g_varchar2_table(34) := '0A202020202F2A6865696768743A202D7765626B69742D66696C6C2D617661696C61626C653B2A2F0A7D0A0A2E64726F7061626C652D7A6F6E652D626F6479207B0A20202020706F736974696F6E3A2072656C61746976653B0A202020206D617267696E';
wwv_flow_imp.g_varchar2_table(35) := '2D746F703A203870783B0A202020203B0A7D0A2E742D546162732D6974656D7B0A20202020637572736F723A20706F696E7465722021696D706F7274616E743B0A7D0A2E742D546162732D6C696E6B7B0A20202020637572736F723A20706F696E746572';
wwv_flow_imp.g_varchar2_table(36) := '2021696D706F7274616E743B0A7D0A236D617053657474696E677344726F70646F776E203E20646976203E206469763A6E74682D6368696C64283129203E206C6162656C7B0A202020206D617267696E2D72696768743A203570783B0A7D0A2E67726964';
wwv_flow_imp.g_varchar2_table(37) := '2D66756C6C2D7370616E7B0A2020202077696474683A20313030252021696D706F7274616E743B0A20202020666C6F61743A206C6566743B0A7D0A2E636F6D706F6E656E74203E2074657874617265617B0A2020202077696474683A203930253B0A2020';
wwv_flow_imp.g_varchar2_table(38) := '20206865696768743A203930253B0A20202020746578742D616C69676E3A2072696768743B0A7D0A2E72656D6F7665203E2074657874617265617B0A2020202077696474683A203930253B0A202020206865696768743A203930253B0A20202020746578';
wwv_flow_imp.g_varchar2_table(39) := '742D616C69676E3A2072696768743B0A7D0A2E73657474696E67732D6C6162656C7B0A20202020666F6E742D7765696768743A20626F6C643B0A2020202070616464696E673A203270782030707820307078203070783B0A7D0A2E7A6F6F6D2D61646469';
wwv_flow_imp.g_varchar2_table(40) := '74696F6E616C2D636F6E7461696E65727B0A202020206D617267696E3A206175746F3B0A202020202F2A746578742D616C69676E3A202D7765626B69742D63656E7465723B2A2F0A7D0A2E7A6F6F6D2D627574746F6E2D636F6E7461696E65727B0A2020';
wwv_flow_imp.g_varchar2_table(41) := '2020666C6F61743A2072696768743B0A202020206D617267696E2D72696768743A20313070783B200A202020206D617267696E2D746F703A20313070783B0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(15494819225060062)
,p_plugin_id=>wwv_flow_imp.id(15489522983001314)
,p_file_name=>'global.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
