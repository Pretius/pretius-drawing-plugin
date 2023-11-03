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
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APPWS'
);
end;
/
 
prompt APPLICATION 100 - test app
--
-- Application Export:
--   Application:     100
--   Name:            test app
--   Date and Time:   09:17 Friday November 3, 2023
--   Exported By:     ADMIN
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 6011114714941373
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
 p_id=>wwv_flow_imp.id(6011114714941373)
,p_plugin_type=>'REGION TYPE'
,p_name=>'PRETIUS_DRAWING_PLUGIN'
,p_display_name=>'Pretius Drawing Plugin'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#map.js',
'#PLUGIN_FILES#control-functions.js'))
,p_css_file_urls=>'#PLUGIN_FILES#global.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION resize (',
'  pi_size in varchar2, ',
'  pi_percent in number default 1',
') return varchar2',
'is',
'    l_clob clob;',
'begin',
'    return ',
'            floor(',
'                to_number(replace(replace(pi_size,''.'','',''),''px'','''')) * pi_percent',
'                ) ||''px'';',
'end resize;',
'----',
'FUNCTION render_region(p_region              IN apex_plugin.t_region,',
'                       p_plugin              IN apex_plugin.t_plugin,',
'                       p_is_printer_friendly IN BOOLEAN)',
'  RETURN apex_plugin.t_region_render_result IS',
'  -- plugin attributes',
'  l_result   apex_plugin.t_region_render_result;',
'  l_attr_01  p_region.attribute_01%TYPE := p_region.attribute_01;',
'  l_editable p_region.attribute_02%TYPE := p_region.attribute_02;',
'  l_resize   p_region.attribute_03%TYPE := replace(NVL(p_region.attribute_03,1),''.'','','');',
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
'  l_region_id := apex_escape.html_attribute(p_region.static_id ||',
'                                            ''_myregion'');',
'  l_ajax_identifier := apex_plugin.get_ajax_identifier;                                          ',
'  -- escape input',
'  l_attr_01 := apex_escape.html(l_attr_01);',
'  --',
'/*---------------------',
'    RENDER START',
'----------------------*/',
'  sys.htp.p(''<div id="drawing-plugin" data-ajax-identifier="''||l_ajax_identifier||''"'' ||',
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
'          <div class="size-input">',
'            <label for="fname">Width:</label>',
'            <input type="text" id="winput" class="inputs" name="width" value="800">',
'          </div>',
'          <div class="size-input">',
'            <label for="fname">Height:</label>',
'            <input type="text" id="hinput" class="inputs" name="height" value="500">',
'          </div>',
'          <button class="t-Button" type="button" onClick="showGrid();">Show Grid</button>',
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
'  sys.htp.p(''<div class="droppable-scroll-parent">',
'    <div class="dropable-zone-body" id="droppable"></div>',
'    </div>',
'  </div>'');',
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
'      if l_editable = ''Y'' then ',
'        l_resize := 1;',
'      end if;',
'      v_json := v_object_id ||',
'        json_object(',
'          ''width'' value resize(v_data(1)(i),l_resize), ',
'          ''height'' value resize(v_data(2)(i),l_resize), ',
'          ''top'' value resize(v_data(3)(i),l_resize), ',
'          ''left'' value resize(v_data(4)(i),l_resize), ',
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
'        htp.p(''<div class="json-data-containers" data-json=''''''|| v_json ||''''''></div>'');',
'      else ',
'        v_json_enclave := v_json_enclave || '','' || v_json;',
'        htp.p(''<div class="json-data-containers" data-json=''''''|| '','' || v_json ||''''''></div>'');',
'      end if;',
'    EXCEPTION WHEN OTHERS THEN ',
'        htp.p(''<div> ERROR '' || i || ''</div>'');',
'    END;',
'  end loop;',
'  ',
'  v_json_enclave := v_json_enclave || ''}'';',
'  --Editable or not',
'  BEGIN',
'      if l_editable = ''Y'' then',
'        apex_javascript.add_onload_code (',
'          p_code => ''recreateFromJson(true);'',',
'          p_key  => ''my_super_widget'');',
'      else ',
'        apex_javascript.add_onload_code (',
'          p_code => ''recreateFromJson(false);'',',
'          p_key  => ''my_super_widget'');',
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
'------------------------------------------------',
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
,p_version_identifier=>'1.2'
,p_about_url=>'https://github.com/pretius/pretius-drawing-plugin'
,p_files_version=>81
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(6012138739954283)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
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
 p_id=>wwv_flow_imp.id(6012402511958468)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
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
 p_id=>wwv_flow_imp.id(6012773373959184)
,p_plugin_attribute_id=>wwv_flow_imp.id(6012402511958468)
,p_display_sequence=>10
,p_display_value=>'Yes'
,p_return_value=>'Y'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(6013138659959691)
,p_plugin_attribute_id=>wwv_flow_imp.id(6012402511958468)
,p_display_sequence=>20
,p_display_value=>'No'
,p_return_value=>'N'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(6013543530965206)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Resize times'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'1'
,p_is_translatable=>false
,p_examples=>'0.7'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'When plugin is not editable, it can be resized to fit smaller or larger screens. In this field you can put a number that will resize all the dimensions of the plan.',
'Number 1 stands for 100%, higher number will scale the plan and components up, lower number will scale it down.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(7049959991066407)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
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
 p_id=>wwv_flow_imp.id(7050590228067537)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
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
 p_id=>wwv_flow_imp.id(6011350669941409)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_name=>'SOURCE_LOCATION'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220726567696F6E203D202428272364726177696E672D706C7567696E27293B0A76617220616A61786964656E746966696572203D20726567696F6E2E646174612822616A61782D6964656E74696669657222293B0A2F2F0A766172206973466972';
wwv_flow_imp.g_varchar2_table(2) := '73744261746368203D20313B0A2F2F0A66756E6374696F6E2073656E64546F4170657828646174612C2069734C617374426174636829207B0A2020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E';
wwv_flow_imp.g_varchar2_table(3) := '207B0A2020202020202020617065782E7365727665722E706C7567696E280A202020202020202020202020616A61786964656E7469666965722C0A2020202020202020202020207B0A202020202020202020202020202020207830313A204A534F4E2E73';
wwv_flow_imp.g_varchar2_table(4) := '7472696E676966792864617461292C0A202020202020202020202020202020207830323A206973466972737442617463680A2020202020202020202020207D2C0A2020202020202020202020207B0A202020202020202020202020202020207375636365';
wwv_flow_imp.g_varchar2_table(5) := '73733A2066756E6374696F6E2028704461746129207B0A2020202020202020202020202020202020202020636F6E736F6C652E6C6F67287044617461293B0A20202020202020202020202020202020202020206966202869734C61737442617463682920';
wwv_flow_imp.g_varchar2_table(6) := '7B0A202020202020202020202020202020202020202020202020617065782E6D6573736167652E73686F775061676553756363657373282744726177696E67206461746120736176656420746F20636F6C6C656374696F6E27293B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(7) := '2020202020202020202020207D0A2020202020202020202020202020202020202020697346697273744261746368203D20303B0A20202020202020202020202020202020202020207265736F6C7665287044617461293B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(8) := '202020207D2C0A202020202020202020202020202020206572726F723A2066756E6374696F6E20286A715848522C20746578745374617475732C206572726F725468726F776E29207B0A2020202020202020202020202020202020202020636F6E736F6C';
wwv_flow_imp.g_varchar2_table(9) := '652E6C6F67286572726F725468726F776E293B0A202020202020202020202020202020202020202072656A656374286572726F725468726F776E293B0A202020202020202020202020202020207D2C0A2020202020202020202020202020202064617461';
wwv_flow_imp.g_varchar2_table(10) := '547970653A20276A736F6E272C0A202020202020202020202020202020206173796E633A20747275650A2020202020202020202020207D0A2020202020202020293B0A202020207D293B0A7D0A0A6173796E632066756E6374696F6E207465737450726F';
wwv_flow_imp.g_varchar2_table(11) := '636573732829207B0A20202020766172206A736F6E44617461203D2073617665546F4A736F6E28293B0A202020200A2020202076617220796F75724A534F4E4F626A656374203D204A534F4E2E7061727365286A736F6E44617461293B0A202020207661';
wwv_flow_imp.g_varchar2_table(12) := '722069203D20303B0A0A202020206173796E632066756E6374696F6E2073656E6442617463682829207B0A2020202020202020636F6E736F6C652E6C6F672827536176696E67206461746127293B0A2020202020202020766172206A736F6E416767203D';
wwv_flow_imp.g_varchar2_table(13) := '207B7D3B0A2020202020202020666F722028636F6E7374206B657920696E20796F75724A534F4E4F626A65637429207B0A20202020202020202020202069662028796F75724A534F4E4F626A6563742E6861734F776E50726F7065727479286B65792929';
wwv_flow_imp.g_varchar2_table(14) := '207B0A20202020202020202020202020202020636F6E7374206F626A203D20796F75724A534F4E4F626A6563745B6B65795D3B0A202020202020202020202020202020206A736F6E4167675B6B65795D203D206F626A3B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(15) := '20202020692B2B3B0A2020202020202020202020202020202069662028692025203130203D3D3D2030207C7C2069203D3D3D204F626A6563742E6B65797328796F75724A534F4E4F626A656374292E6C656E67746829207B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(16) := '20202020202020202061776169742073656E64546F41706578286A736F6E4167672C2069203D3D3D204F626A6563742E6B65797328796F75724A534F4E4F626A656374292E6C656E677468293B0A20202020202020202020202020202020202020206A73';
wwv_flow_imp.g_varchar2_table(17) := '6F6E416767203D207B7D3B0A20202020202020202020202020202020202020206966202869203D3D3D204F626A6563742E6B65797328796F75724A534F4E4F626A656374292E6C656E6774682920627265616B3B0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(18) := '207D0A2020202020202020202020207D0A20202020202020207D0A202020207D0A0A2020202061776169742073656E64426174636828293B202F2F205374617274207468652070726F636573730A7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(6014165922967689)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_file_name=>'plugin-ajax-processes.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2A0A202A20526563726561746573207468652048544D4C20656C656D656E74732066726F6D204A534F4E20646174612E0A202A0A202A2040706172616D207B737472696E677D206A736F6E44617461202D20546865204A534F4E2064617461207265';
wwv_flow_imp.g_varchar2_table(2) := '70726573656E74696E672074686520656C656D656E74732E0A202A2040706172616D207B626F6F6C65616E7D206564697461626C65202D20496E6469636174657320776865746865722074686520656C656D656E74732073686F756C6420626520656469';
wwv_flow_imp.g_varchar2_table(3) := '7461626C652E0A202A2F0A66756E6374696F6E20726563726561746546726F6D4A736F6E28206564697461626C6529207B0A20202020636F6E736F6C652E6C6F672827726563726561746546726F6D4A736F6E27293B0A202020202F2F4665746368696E';
wwv_flow_imp.g_varchar2_table(4) := '672074686520646174612066726F6D20646976730A20202020766172206461746146726F6D44697673203D202428222E6A736F6E2D646174612D636F6E7461696E65727322293B0A20202020636F6E736F6C652E6C6F6728242820222E6A736F6E2D6461';
wwv_flow_imp.g_varchar2_table(5) := '74612D636F6E7461696E6572732220292E6C656E677468290A20202020766172206A736F6E46726F6D44697673203D20227B223B0A20202020666F7220286C657420696E646578203D20303B20696E646578203C206461746146726F6D446976732E6C65';
wwv_flow_imp.g_varchar2_table(6) := '6E6774683B20696E6465782B2B29207B0A2020202020202020636F6E737420656C656D656E74203D206461746146726F6D446976735B696E6465785D3B0A20202020202020206A736F6E46726F6D44697673203D206A736F6E46726F6D44697673202B20';
wwv_flow_imp.g_varchar2_table(7) := '2428656C656D656E74292E6461746128226A736F6E22293B0A202020207D0A202020206A736F6E46726F6D44697673203D206A736F6E46726F6D44697673202B20277D273B0A202020206A736F6E44617461203D206A736F6E46726F6D446976733B0A20';
wwv_flow_imp.g_varchar2_table(8) := '2020202F2F20506172736520746865204A534F4E20737472696E6720746F20676574207468652064617461206F626A6563740A202020207661722064617461203D204A534F4E2E7061727365286A736F6E44617461293B0A0A202020202F2F2052656372';
wwv_flow_imp.g_varchar2_table(9) := '65617465207468652064726F707061626C65207A6F6E652077697468207468652073617665642073697A6520616E6420706F736974696F6E0A2020202069662028216564697461626C6529207B0A20202020202020202F2F242827237772617070657227';
wwv_flow_imp.g_varchar2_table(10) := '295B305D2E696E6E657248544D4C203D2022223B0A202020207D0A202020202F2F7661722064726F707061626C65446976203D206564697461626C65203F202428272364726F707061626C652729203A202428273C6469762069643D2264726F70706162';
wwv_flow_imp.g_varchar2_table(11) := '6C65223E3C2F6469763E27293B0A202020207661722064726F707061626C65446976203D202428272364726F707061626C6527293B0A20202020766172207769647468203D20284F626A6563742E6B6579732864617461292E6C656E677468203E203029';
wwv_flow_imp.g_varchar2_table(12) := '203F20646174612E64726F707061626C652E7769647468203A20646F63756D656E742E676574456C656D656E7442794964282277696E70757422292E76616C75653B0A2020202076617220686569676874203D20284F626A6563742E6B65797328646174';
wwv_flow_imp.g_varchar2_table(13) := '61292E6C656E677468203E203029203F20646174612E64726F707061626C652E686569676874203A20646F63756D656E742E676574456C656D656E7442794964282268696E70757422292E76616C75653B0A20202020696620286564697461626C652920';
wwv_flow_imp.g_varchar2_table(14) := '7B0A202020202020202064726F707061626C654469762E637373287B0A20202020202020202020202077696474683A2077696474682C0A2020202020202020202020206865696768743A206865696768740A20202020202020207D293B0A202020207D20';
wwv_flow_imp.g_varchar2_table(15) := '656C7365207B0A202020202020202064726F707061626C654469762E637373287B0A20202020202020202020202077696474683A2077696474682C0A2020202020202020202020206865696768743A206865696768742C0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(16) := '706F736974696F6E3A202772656C6174697665272C0A2020202020202020202020206261636B67726F756E64436F6C6F723A202723656565270A20202020202020207D293B0A202020207D0A0A202020202F2F2049746572617465206F76657220746865';
wwv_flow_imp.g_varchar2_table(17) := '206469767320696E20746865204A534F4E206461746120616E64207265637265617465207468656D0A20202020666F722028766172206B657920696E206461746129207B0A2020202020202020696620286B657920213D3D202764726F707061626C6527';
wwv_flow_imp.g_varchar2_table(18) := '29207B0A2020202020202020202020207661722064697644617461203D20646174615B6B65795D3B0A20202020202020202020202076617220646976203D202428273C64697620636C6173733D2272656D6F7665222027202B2028646976446174612E61';
wwv_flow_imp.g_varchar2_table(19) := '7661696C61626C65203D3D3D20275927203F20276F6E436C69636B3D2227202B20646976446174612E6F6E436C69636B202B20272227203A20272729202B20273E3C2F6469763E27293B0A202020202020202020202020696620286564697461626C6529';
wwv_flow_imp.g_varchar2_table(20) := '207B0A20202020202020202020202020202020646976203D202428273C64697620636C6173733D2272656D6F7665222027202B20276F6E436C69636B3D2273656C65637428293B2227202B20273E3C2F6469763E27293B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(21) := '7D0A0A2020202020202020202020206469762E637373287B0A2020202020202020202020202020202077696474683A20646976446174612E77696474682C0A202020202020202020202020202020206865696768743A20646976446174612E6865696768';
wwv_flow_imp.g_varchar2_table(22) := '742C0A20202020202020202020202020202020746F703A20646976446174612E746F702C0A202020202020202020202020202020206C6566743A20646976446174612E6C6566742C0A20202020202020202020202020202020726F746174653A20646976';
wwv_flow_imp.g_varchar2_table(23) := '446174612E726F746174652C0A20202020202020202020202020202020706F736974696F6E3A20276162736F6C757465272F2F2C0A2020202020202020202020207D293B0A2020202020202020202020206469762E6174747228276964272C206B657929';
wwv_flow_imp.g_varchar2_table(24) := '3B0A2020202020202020202020206469762E616464436C61737328646976446174612E636C617373293B202F2F204164642074686520736176656420636C61737320746F2074686520726563726561746564206469760A2020202020202020202020202F';
wwv_flow_imp.g_varchar2_table(25) := '2F2043726561746520616E20696E70757420656C656D656E742C207365742074686520746578742066726F6D20746865204A534F4E2C20616E642061646420617661696C6162696C69747920636C6173730A202020202020202020202020616464496E70';
wwv_flow_imp.g_varchar2_table(26) := '7574416E64417661696C6162696C697479436C617373286469762C2064697644617461293B0A20202020202020202020202061646444697669636F6E7328646976293B0A20202020202020202020202064726F707061626C654469762E617070656E6428';
wwv_flow_imp.g_varchar2_table(27) := '646976293B0A2020202020202020202020202F2F496E6E65722048544D4C20666F7220636F6D706C69636174656420636F6D706F6E656E74730A20202020202020202020202069662028646976446174612E636C6173732E696E636C7564657328227061';
wwv_flow_imp.g_varchar2_table(28) := '726B696E672D73706163652229207C7C20646976446174612E636C6173732E696E636C7564657328227061726B696E672D73706163652D766572746963616C2229207C7C20646976446174612E636C6173732E696E636C7564657328226C6162656C2229';
wwv_flow_imp.g_varchar2_table(29) := '29207B0A0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020206469765B305D2E696E7365727441646A6163656E7448544D4C28276265666F7265656E64272C2028646976446174612E696E6E657248746D6C29';
wwv_flow_imp.g_varchar2_table(30) := '2E7265706C616365416C6C282740272C2027222729293B0A2020202020202020202020207D0A20202020202020207D0A202020207D0A20202020696620286564697461626C6529207B0A20202020202020202F2F52656163746976617465206472616767';
wwv_flow_imp.g_varchar2_table(31) := '61626C6520616E6420726573697A61626C650A20202020202020202428222E72656D6F766522290A2020202020202020202020202E726573697A61626C6528290A2020202020202020202020202E647261676761626C6528293B0A202020207D20656C73';
wwv_flow_imp.g_varchar2_table(32) := '65207B0A20202020202020202F2F20417070656E6420746865207265637265617465642064726F707061626C65207A6F6E6520746F2074686520646F63756D656E7420626F6479206F7220616E79206465736972656420706172656E7420656C656D656E';
wwv_flow_imp.g_varchar2_table(33) := '740A2020202020202020242827237772617070657227292E617070656E642864726F707061626C65446976293B0A202020207D0A202020202F2F46696C6C2073697A65206974656D7320776974682064726F707061626C652076616C7565730A20202020';
wwv_flow_imp.g_varchar2_table(34) := '747279207B0A20202020202020207661722073656C656374456C656D656E74203D20646F63756D656E742E717565727953656C6563746F7228222377696E70757422293B0A20202020202020207661722073656C656374456C656D656E7432203D20646F';
wwv_flow_imp.g_varchar2_table(35) := '63756D656E742E717565727953656C6563746F7228222368696E70757422293B0A202020202020202073656C656374456C656D656E742E76616C7565203D2077696474683B0A202020202020202073656C656374456C656D656E74322E76616C7565203D';
wwv_flow_imp.g_varchar2_table(36) := '206865696768743B0A202020207D206361746368202865727229207B0A2020202020202020636F6E736F6C652E6C6F6728274E6F20696E7075747327293B0A202020207D0A202020202428272E72656D6F766527292E62696E6428276472616773746F70';
wwv_flow_imp.g_varchar2_table(37) := '272C2066756E6374696F6E202829207B2073656C656374287468697329207D293B0A7D0A2F2A2A0A202A20436F6E7665727473207468652064617461206F6620726573697A61626C6520616E6420647261676761626C652064697620656C656D656E7473';
wwv_flow_imp.g_varchar2_table(38) := '20696E746F204A534F4E20666F726D61742E0A202A0A202A204072657475726E73207B737472696E677D20546865204A534F4E20737472696E6720726570726573656E746174696F6E206F662074686520646174612E0A202A2F0A66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(39) := '73617665546F4A736F6E2829207B0A202020202F2F2043726561746520616E206F626A65637420746F2073746F72652074686520646174610A20202020766172206A736F6E44617461203D207B7D3B0A0A202020202F2F20476574207468652073697A65';
wwv_flow_imp.g_varchar2_table(40) := '20616E6420706F736974696F6E206F66207468652064726F707061626C65206469760A202020207661722064726F707061626C65446976203D202428222364726F707061626C6522293B0A202020207661722064726F707061626C6544617461203D207B';
wwv_flow_imp.g_varchar2_table(41) := '0A202020202020202077696474683A20242864726F707061626C65446976292E6373732822776964746822292C0A20202020202020206865696768743A20242864726F707061626C65446976292E637373282268656967687422292C0A20202020202020';
wwv_flow_imp.g_varchar2_table(42) := '20746F703A2064726F707061626C654469762E6F666673657428292E746F702C0A20202020202020206C6566743A2064726F707061626C654469762E6F666673657428292E6C6566742C0A2020202020202020636C6173733A2064726F707061626C6544';
wwv_flow_imp.g_varchar2_table(43) := '69762E617474722827636C61737327292C0A202020202020202073706F7449643A2064726F707061626C654469762E69640A202020207D3B0A202020206A736F6E446174615B2264726F707061626C65225D203D2064726F707061626C65446174613B0A';
wwv_flow_imp.g_varchar2_table(44) := '0A202020202F2F2049746572617465206F766572206561636820726573697A61626C6520616E6420647261676761626C65206469760A202020202428222E72656D6F766522292E656163682866756E6374696F6E202829207B0A20202020202020207661';
wwv_flow_imp.g_varchar2_table(45) := '72206964203D20746869732E69643B0A20202020202020207661722064697644617461203D207B0A20202020202020202020202077696474683A20242874686973292E6373732822776964746822292C0A2020202020202020202020206865696768743A';
wwv_flow_imp.g_varchar2_table(46) := '20242874686973292E637373282268656967687422292C0A202020202020202020202020746F703A20242874686973292E6373732822746F7022292C0A2020202020202020202020206C6566743A20242874686973292E63737328226C65667422292C0A';
wwv_flow_imp.g_varchar2_table(47) := '202020202020202020202020636C6173733A20242874686973292E617474722827636C61737327292C0A202020202020202020202020746578743A20242874686973292E66696E642827746578746172656127292E76616C28292C0A2020202020202020';
wwv_flow_imp.g_varchar2_table(48) := '20202020726F746174653A20242874686973292E6373732822726F7461746522292C0A20202020202020202020202073706F7449643A2069642C0A202020202020202020202020696E6E657248746D6C3A2028746869732E696E6E657248544D4C292E72';
wwv_flow_imp.g_varchar2_table(49) := '65706C616365416C6C282722272C20274027292E7265706C616365282F285C725C6E7C5C6E7C5C72292F676D2C202222290A20202020202020207D3B0A20202020202020206A736F6E446174615B69645D203D20646976446174613B0A202020207D293B';
wwv_flow_imp.g_varchar2_table(50) := '0A0A202020202F2F20436F6E7665727420746865204A534F4E206F626A65637420746F206120737472696E670A20202020766172206A736F6E537472696E67203D204A534F4E2E737472696E67696679286A736F6E44617461293B0A202020202F2F636F';
wwv_flow_imp.g_varchar2_table(51) := '6E736F6C652E6C6F67286A736F6E537472696E67293B0A2020202072657475726E206A736F6E537472696E673B0A7D0A2F2A2A0A202A204368616E676573207468652073697A65206F66207468652064726F707061626C6520656C656D656E7420626173';
wwv_flow_imp.g_varchar2_table(52) := '6564206F6E2074686520696E7075742076616C7565732E0A202A2F0A66756E6374696F6E206368616E676553697A652829207B0A202020207661722077203D20646F63756D656E742E676574456C656D656E7442794964282277696E70757422292E7661';
wwv_flow_imp.g_varchar2_table(53) := '6C75653B0A202020207661722068203D20646F63756D656E742E676574456C656D656E7442794964282268696E70757422292E76616C75653B0A0A202020207661722064617461203D205B0A20202020202020207B2057696474683A20772C2048656967';
wwv_flow_imp.g_varchar2_table(54) := '68743A2068207D0A202020205D3B0A0A202020202428272364726F707061626C6527292E63737328277769647468272C2077293B0A202020202428272364726F707061626C6527292E6373732827686569676874272C2068293B0A7D0A2F2A2A0A202A20';
wwv_flow_imp.g_varchar2_table(55) := '47656E65726174657320612072616E646F6D20494420737472696E672E0A202A0A202A204072657475726E73207B737472696E677D205468652067656E65726174656420494420737472696E672E0A202A2F0A66756E6374696F6E206D616B6569642829';
wwv_flow_imp.g_varchar2_table(56) := '207B0A2020202072657475726E20276E65772D69642D27202B204D6174682E72616E646F6D28292E746F537472696E67283336292E73756273747228322C2039293B0A7D0A0A66756E6374696F6E2070726570617265456469746F722829207B0A202020';
wwv_flow_imp.g_varchar2_table(57) := '207661722078203D206E756C6C3B0A202020207661722074203D2027273B0A202020202F2F4D616B6520656C656D656E7420647261676761626C650A202020202428222E6472616722292E647261676761626C65287B0A202020202020202068656C7065';
wwv_flow_imp.g_varchar2_table(58) := '723A2027636C6F6E65272C0A2020202020202020637572736F723A20276D6F7665272C0A2020202020202020746F6C6572616E63653A2027666974272C0A20202020202020207265766572743A20747275650A202020207D293B0A0A2020202024282223';
wwv_flow_imp.g_varchar2_table(59) := '64726F707061626C6522292E64726F707061626C65287B0A20202020202020206163636570743A20272E64726167272C0A2020202020202020616374697665436C6173733A202264726F702D61726561222C0A202020202020202064726F703A2066756E';
wwv_flow_imp.g_varchar2_table(60) := '6374696F6E2028652C20756929207B0A20202020202020202020202069662028242875692E647261676761626C65295B305D2E6964203D3D2022647261672229207B0A2020202020202020202020202020202078203D2075692E68656C7065722E636C6F';
wwv_flow_imp.g_varchar2_table(61) := '6E6528293B0A2020202020202020202020202020202075692E68656C7065722E72656D6F766528293B0A20202020202020202020202020202020782E647261676761626C65287B0A202020202020202020202020202020202020202068656C7065723A20';
wwv_flow_imp.g_varchar2_table(62) := '276F726967696E616C272C0A2020202020202020202020202020202020202020637572736F723A20276D6F7665272C0A20202020202020202020202020202020202020202F2F636F6E7461696E6D656E743A20272364726F707061626C65272C0A202020';
wwv_flow_imp.g_varchar2_table(63) := '2020202020202020202020202020202020746F6C6572616E63653A2027666974272C0A202020202020202020202020202020202020202064726F703A2066756E6374696F6E20286576656E742C20756929207B0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(64) := '2020202020202020242875692E647261676761626C65292E72656D6F766528293B0A20202020202020202020202020202020202020207D2C0A2020202020202020202020202020202020202020647261673A2066756E6374696F6E20286576656E742C20';
wwv_flow_imp.g_varchar2_table(65) := '756929207B0A20202020202020202020202020202020202020202020202074203D2075692E706F736974696F6E3B0A20202020202020202020202020202020202020207D2C0A2020202020202020202020202020202020202020677269643A205B312C20';
wwv_flow_imp.g_varchar2_table(66) := '315D202F2F2041646A7573742074686520677269642073697A6520686572652028696E20706978656C73290A202020202020202020202020202020207D293B0A0A20202020202020202020202020202020782E726573697A61626C65287B0A2020202020';
wwv_flow_imp.g_varchar2_table(67) := '202020202020202020202020202020677269643A205B312C20315D0A202020202020202020202020202020207D293B0A20202020202020202020202020202020766172206E65774964203D206D616B65696428293B0A0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(68) := '202020782E6174747228276964272C206E65774964293B0A20202020202020202020202020202020782E616464436C617373282772656D6F766527293B0A20202020202020202020202020202020782E72656D6F7665436C61737328276472616727293B';
wwv_flow_imp.g_varchar2_table(69) := '0A202020202020202020202020202020202F2F41646420696E70757420696E746F204449560A202020202020202020202020202020206966202828782E686173436C61737328227061726B696E672D73706163652229207C7C2028782E686173436C6173';
wwv_flow_imp.g_varchar2_table(70) := '7328227061726B696E672D73706163652D766572746963616C222929292026262021782E66696E6428272E69642D696E70757427292E6C656E67746829207B0A202020202020202020202020202020202020202076617220696E707574203D202428273C';
wwv_flow_imp.g_varchar2_table(71) := '746578746172656120747970653D22746578742220706C616365686F6C6465723D22456E74657220746578742220636C6173733D2269642D696E707574222F3E27293B0A2020202020202020202020202020202020202020782E617070656E6428696E70';
wwv_flow_imp.g_varchar2_table(72) := '7574293B0A202020202020202020202020202020207D0A0A20202020202020202020202020202020782E617070656E64546F28272364726F707061626C6527293B0A202020202020202020202020202020202428272E64656C65746527292E6F6E282763';
wwv_flow_imp.g_varchar2_table(73) := '6C69636B272C2066756E6374696F6E202829207B0A2020202020202020202020202020202020202020242874686973292E706172656E7428292E706172656E7428277370616E27292E72656D6F766528293B0A202020202020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(74) := '293B0A202020202020202020202020202020202428272E64656C65746527292E706172656E7428292E706172656E7428277370616E27292E64626C636C69636B2866756E6374696F6E202829207B0A202020202020202020202020202020202020202024';
wwv_flow_imp.g_varchar2_table(75) := '2874686973292E72656D6F766528293B0A202020202020202020202020202020207D293B0A20202020202020202020202020202020766172206C6566744F6666736574203D204E756D62657228785B305D2E6F66667365744C656674293B0A2020202020';
wwv_flow_imp.g_varchar2_table(76) := '202020202020202020202076617220746F704F6666736574203D204E756D62657228785B305D2E6F6666736574546F70293B0A0A20202020202020202020202020202020782E6373732827706F736974696F6E272C20276162736F6C75746527293B0A20';
wwv_flow_imp.g_varchar2_table(77) := '2020202020202020202020202020202F2F43616C6962726174696F6E206F662064726F70206D617267696E730A2020202020202020202020202020202076617220706172656E744C6566744D617267696E203D20282428272364726177696E672D706C75';
wwv_flow_imp.g_varchar2_table(78) := '67696E27292E706172656E7428292E63737328226D617267696E4C6566742229292E7265706C61636528277078272C2727293B0A2020202020202020202020202020202076617220656C656D656E74203D202428272364726177696E672D706C7567696E';
wwv_flow_imp.g_varchar2_table(79) := '27292E706172656E7428293B0A202020202020202020202020202020207661722072656374203D202428656C656D656E74295B305D2E676574426F756E64696E67436C69656E745265637428293B0A202020202020202020202020202020207661722070';
wwv_flow_imp.g_varchar2_table(80) := '6172656E74546F704D617267696E203D20726563742E746F703B0A20202020202020202020202020202020766172206C6566744D617267696E56616C203D202428272E64726F70646F776E27292E6461746128276C6566744D617267696E27293B0A2020';
wwv_flow_imp.g_varchar2_table(81) := '202020202020202020202020202076617220746F704D617267696E56616C203D202428272E64726F70646F776E27292E646174612827746F704D617267696E27293B0A20202020202020202020202020202020782E63737328226C656674222C206C6566';
wwv_flow_imp.g_varchar2_table(82) := '744F66667365742D706172656E744C6566744D617267696E202B206C6566744D617267696E56616C293B202F2F3131206973206C656674206D617267696E206F6620636F6D706F6E656E74202B20626F72646572203170780A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(83) := '2020202020782E6373732822746F70222C20746F704F6666736574202D20746F704D617267696E56616C293B202F2F39206973206D617267696E206F662064726F707A6F6E65202B20626F7264657220312070780A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(84) := '20782E62696E6428276472616773746F70272C2066756E6374696F6E202829207B2073656C656374287468697329207D293B0A2020202020202020202020207D0A20202020202020207D0A202020207D293B0A202020202428222372656D6F76652D6472';
wwv_flow_imp.g_varchar2_table(85) := '616722292E64726F707061626C65287B0A202020202020202064726F703A2066756E6374696F6E20286576656E742C20756929207B0A202020202020202020202020242875692E647261676761626C65292E72656D6F766528293B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(86) := '7D2C0A2020202020202020686F766572436C6173733A202272656D6F76652D647261672D686F766572222C0A20202020202020206163636570743A20272E72656D6F7665270A202020207D293B0A20202020636F6E73742073656C656374456C656D656E';
wwv_flow_imp.g_varchar2_table(87) := '74203D20646F63756D656E742E717565727953656C6563746F7228222377696E70757422293B0A20202020636F6E73742073656C656374456C656D656E7432203D20646F63756D656E742E717565727953656C6563746F7228222368696E70757422293B';
wwv_flow_imp.g_varchar2_table(88) := '0A20202020747279207B0A202020202020202073656C656374456C656D656E742E6164644576656E744C697374656E657228226368616E6765222C20286576656E7429203D3E207B0A2020202020202020202020206368616E676553697A6528293B0A20';
wwv_flow_imp.g_varchar2_table(89) := '202020202020207D293B0A202020202020202073656C656374456C656D656E74322E6164644576656E744C697374656E657228226368616E6765222C20286576656E7429203D3E207B0A2020202020202020202020206368616E676553697A6528293B0A';
wwv_flow_imp.g_varchar2_table(90) := '20202020202020207D293B0A202020207D206361746368202865727229207B0A0A202020207D0A0A202020202F2F6368616E676553697A6528293B0A7D0A0A2F2A2A0A202A20416464732069636F6E7320746F2074686520676976656E20646976206261';
wwv_flow_imp.g_varchar2_table(91) := '736564206F6E2069747320636C61737365732E0A202A0A202A2040706172616D207B6A51756572797D20646976202D20546865206A5175657279206F626A65637420726570726573656E74696E67207468652064697620656C656D656E742E0A202A2040';
wwv_flow_imp.g_varchar2_table(92) := '72657475726E73207B6A51756572797D20546865206D6F646966696564206A5175657279206F626A65637420776974682061646465642069636F6E732E0A202A2F0A66756E6374696F6E2061646444697669636F6E732864697629207B0A202020207661';
wwv_flow_imp.g_varchar2_table(93) := '7220636C617373546F49636F6E203D207B0A2020202020202020276172726F772D6C656674273A202766612066612D6172726F772D6C656674272C0A2020202020202020276172726F772D7269676874273A202766612066612D6172726F772D72696768';
wwv_flow_imp.g_varchar2_table(94) := '74272C0A2020202020202020276172726F772D7570273A202766612066612D6172726F772D7570272C0A2020202020202020276172726F772D646F776E273A202766612066612D6172726F772D646F776E272C0A2020202020202020276172726F772D69';
wwv_flow_imp.g_varchar2_table(95) := '6E2D65617374273A202766612066612D626F782D6172726F772D696E2D65617374272C0A2020202020202020277061726B696E672D73706163652D70617261706C65676963273A202766612066612D776865656C6368616972270A20202020202020202F';
wwv_flow_imp.g_varchar2_table(96) := '2F2041646420616E79206164646974696F6E616C206D617070696E677320686572650A202020207D3B0A0A202020206469762E656163682866756E6374696F6E202829207B0A2020202020202020666F72202876617220636C6173734E616D6520696E20';
wwv_flow_imp.g_varchar2_table(97) := '636C617373546F49636F6E29207B0A20202020202020202020202069662028242874686973292E686173436C61737328636C6173734E616D652929207B0A202020202020202020202020202020207661722069636F6E203D202428273C6920636C617373';
wwv_flow_imp.g_varchar2_table(98) := '3D2227202B20636C617373546F49636F6E5B636C6173734E616D655D202B2027223E3C2F693E27293B0A20202020202020202020202020202020242874686973292E617070656E642869636F6E293B0A2020202020202020202020202020202062726561';
wwv_flow_imp.g_varchar2_table(99) := '6B3B0A2020202020202020202020207D0A20202020202020207D0A202020207D293B0A0A2020202072657475726E206469763B0A7D0A2F2A2A0A202A204164647320616E20696E70757420656C656D656E7420616E642073657473207468652074657874';
wwv_flow_imp.g_varchar2_table(100) := '2066726F6D20746865204A534F4E20746F2074686520676976656E20656C656D656E742E0A202A20416C736F206164647320616E20617661696C6162696C69747920636C617373206261736564206F6E2074686520646976446174612E617661696C6162';
wwv_flow_imp.g_varchar2_table(101) := '6C652076616C75652E0A202A0A202A2040706172616D207B6A51756572797D20656C656D656E74202D20546865206A517565727920656C656D656E7420746F2077686963682074686520696E70757420656C656D656E7420616E6420636C617373207368';
wwv_flow_imp.g_varchar2_table(102) := '6F756C642062652061646465642E0A202A2040706172616D207B4F626A6563747D2064697644617461202D20546865206469762064617461206F626A65637420636F6E7461696E696E6720746865207465787420616E6420617661696C6162696C697479';
wwv_flow_imp.g_varchar2_table(103) := '2076616C7565732E0A202A2F0A66756E6374696F6E20616464496E707574416E64417661696C6162696C697479436C61737328656C656D656E742C206469764461746129207B0A2020202069662028656C656D656E742E686173436C6173732822706172';
wwv_flow_imp.g_varchar2_table(104) := '6B696E672D73706163652229207C7C20656C656D656E742E686173436C61737328227061726B696E672D73706163652D766572746963616C2229207C7C20656C656D656E742E686173436C61737328226C6162656C222929207B0A202020202020202076';
wwv_flow_imp.g_varchar2_table(105) := '617220696E707574203D202428273C746578746172656120747970653D22746578742220706C616365686F6C6465723D222220636C6173733D2269642D696E707574222F3E27293B0A2020202020202020696E7075742E76616C28646976446174612E74';
wwv_flow_imp.g_varchar2_table(106) := '657874293B0A2020202020202020656C656D656E742E617070656E6428696E707574293B0A0A20202020202020202F2F2044696374696F6E61727920666F7220617661696C6162696C69747920636C61737365730A202020202020202076617220617661';
wwv_flow_imp.g_varchar2_table(107) := '696C6162696C697479436C6173736573203D207B0A2020202020202020202020202759273A2027617661696C61626C65272C0A202020202020202020202020274E273A20276E6F742D617661696C61626C65272C0A202020202020202020202020275227';
wwv_flow_imp.g_varchar2_table(108) := '3A20277265736572766564272C0A2020202020202020202020202F2F2041646420616E79206164646974696F6E616C206D617070696E677320686572650A20202020202020207D3B0A0A20202020202020202F2F2041646420636C617373206261736564';
wwv_flow_imp.g_varchar2_table(109) := '206F6E20617661696C6162696C6974790A202020202020202076617220617661696C6162696C697479436C617373203D20617661696C6162696C697479436C61737365735B646976446174612E617661696C61626C655D207C7C2027273B0A2020202020';
wwv_flow_imp.g_varchar2_table(110) := '2020206966202821656C656D656E742E686173436C61737328226C6162656C222929207B0A202020202020202020202020656C656D656E742E616464436C61737328617661696C6162696C697479436C617373293B0A20202020202020207D0A20202020';
wwv_flow_imp.g_varchar2_table(111) := '7D0A7D0A0A2F2A2A0A202A20526F746174657320616E20656C656D656E7420627920612073706563696669656420616E676C6520696E20646567726565732E0A202A0A202A204066756E6374696F6E0A202A2040706172616D207B737472696E677D2070';
wwv_flow_imp.g_varchar2_table(112) := '695F6964202D20546865204944206F662074686520656C656D656E7420746F20626520726F74617465642E0A202A2040706172616D207B6E756D6265727D205B70695F76616C75653D31305D202D2054686520616E676C6520696E206465677265657320';
wwv_flow_imp.g_varchar2_table(113) := '627920776869636820746F20726F746174652074686520656C656D656E74202864656661756C742069732031302064656772656573292E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374696F6E20726F746174652870695F6964';
wwv_flow_imp.g_varchar2_table(114) := '2C2070695F76616C756529207B0A2020202076617220726F746174654279446567203D2070695F76616C7565207C7C2031303B0A202020207661722074686973456C656D656E74203D20242870695F6964292E706172656E7428293B0A20202020766172';
wwv_flow_imp.g_varchar2_table(115) := '2063757272656E74446567203D2074686973456C656D656E742E6373732822726F7461746522293B0A202020206966202863757272656E74446567203D3D20276E6F6E652729207B0A202020202020202074686973456C656D656E742E6373732822726F';
wwv_flow_imp.g_varchar2_table(116) := '74617465222C20726F746174654279446567202B202264656722293B0A202020207D20656C7365207B0A202020202020202063757272656E74446567203D2063757272656E744465672E6D61746368282F5C642B2F295B305D3B0A202020202020202063';
wwv_flow_imp.g_varchar2_table(117) := '757272656E744465672E746F537472696E6728293B0A2020202020202020766172206E6577446567203D204E756D6265722863757272656E7444656729202B204E756D62657228726F746174654279446567293B0A202020202020202074686973456C65';
wwv_flow_imp.g_varchar2_table(118) := '6D656E742E6373732822726F74617465222C206E6577446567202B202264656722293B0A202020207D0A7D0A0A2F2A2A0A202A2053656C65637473206F7220646573656C6563747320616E20656C656D656E74206261736564206F6E2069747320637572';
wwv_flow_imp.g_varchar2_table(119) := '72656E742073746174652E0A202A0A202A204066756E6374696F6E0A202A2040706172616D207B48544D4C456C656D656E747D205B70695F656C656D656E745D202D2054686520656C656D656E7420746F2062652073656C65637465642E204966206E6F';
wwv_flow_imp.g_varchar2_table(120) := '742070726F76696465642C20746865206576656E74207461726765742077696C6C20626520757365642E0A202A204072657475726E73207B766F69647D0A202A2F0A66756E6374696F6E2073656C6563742870695F656C656D656E7429207B0A20202020';
wwv_flow_imp.g_varchar2_table(121) := '6966202870695F656C656D656E7429207B0A20202020202020207661722073656C6563746564456C656D656E74203D2070695F656C656D656E743B0A202020207D20656C7365207B0A20202020202020207661722073656C6563746564456C656D656E74';
wwv_flow_imp.g_varchar2_table(122) := '203D20746869732E6576656E742E7461726765743B0A202020207D0A202020206966202821242873656C6563746564456C656D656E74292E686173436C617373282775692D726573697A61626C652D68616E646C65272929207B0A202020202020202069';
wwv_flow_imp.g_varchar2_table(123) := '66202821242873656C6563746564456C656D656E74292E686173436C6173732827636F6D706F6E656E7427292026262021242873656C6563746564456C656D656E74292E686173436C617373282769642D696E70757427292026262021242873656C6563';
wwv_flow_imp.g_varchar2_table(124) := '746564456C656D656E74292E686173436C617373282769676E6F72652D73656C6563746564272929207B0A20202020202020202020202073656C6563746564456C656D656E74203D20242873656C6563746564456C656D656E74292E636C6F7365737428';
wwv_flow_imp.g_varchar2_table(125) := '272E636F6D706F6E656E7427293B0A20202020202020207D0A202020202020202069662028242873656C6563746564456C656D656E74292E686173436C617373282773656C6563746564272929207B0A202020202020202020202020242873656C656374';
wwv_flow_imp.g_varchar2_table(126) := '6564456C656D656E74292E72656D6F7665436C617373282773656C656374656427293B0A20202020202020207D20656C73652069662028242873656C6563746564456C656D656E74292E686173436C6173732827636F6D706F6E656E74272929207B0A20';
wwv_flow_imp.g_varchar2_table(127) := '2020202020202020202020242873656C6563746564456C656D656E74292E616464436C617373282773656C656374656427293B0A20202020202020207D20656C7365206966202821242873656C6563746564456C656D656E74292E686173436C61737328';
wwv_flow_imp.g_varchar2_table(128) := '27636F6D706F6E656E74272929207B0A202020202020202020202020242873656C6563746564456C656D656E74292E66696E6428272E636F6D706F6E656E7427292E616464436C617373282773656C656374656427293B0A20202020202020207D0A2020';
wwv_flow_imp.g_varchar2_table(129) := '20207D0A7D0A0A2F2A2A0A202A20446573656C6563747320616C6C20656C656D656E7473207769746820746865202773656C65637465642720636C6173732E0A202A204066756E6374696F6E0A202A204072657475726E73207B766F69647D0A202A2F0A';
wwv_flow_imp.g_varchar2_table(130) := '66756E6374696F6E20646573656C656374416C6C2829207B0A2020202076617220616C6C53656C6563746564203D2041727261792E66726F6D282428272E73656C65637465642729293B0A20202020616C6C53656C65637465642E666F72456163682865';
wwv_flow_imp.g_varchar2_table(131) := '6C656D656E74203D3E207B0A20202020202020202428656C656D656E74292E72656D6F7665436C617373282773656C656374656427293B0A202020207D293B0A7D0A0A2F2A2A0A202A20416C69676E73206469767320776974682074686520636C617373';
wwv_flow_imp.g_varchar2_table(132) := '202273656C6563746564222065697468657220686F72697A6F6E74616C6C79206F7220766572746963616C6C79206261736564206F6E207468652073706563696669656420617869732E0A202A2040706172616D207B737472696E677D2061786973202D';
wwv_flow_imp.g_varchar2_table(133) := '20546865206178697320746F20616C69676E2074686520646976732E205573652022686F72697A6F6E74616C2220666F7220686F72697A6F6E74616C20616C69676E6D656E7420616E642022766572746963616C2220666F7220766572746963616C2061';
wwv_flow_imp.g_varchar2_table(134) := '6C69676E6D656E742E0A202A2F0A66756E6374696F6E20616C69676E53656C656374656444697673286178697329207B0A20202020636F6E73742073656C656374656444697673203D20646F63756D656E742E717565727953656C6563746F72416C6C28';
wwv_flow_imp.g_varchar2_table(135) := '272E73656C656374656427293B0A0A202020202F2F20436865636B2069662074686572652061726520616E792073656C656374656420646976732C206966206E6F742C2074686572652773206E6F7468696E6720746F20616C69676E2E0A202020206966';
wwv_flow_imp.g_varchar2_table(136) := '202873656C6563746564446976732E6C656E677468203D3D3D203029207B0A202020202020202072657475726E3B0A202020207D0A0A202020206966202861786973203D3D3D2027686F72697A6F6E74616C2729207B0A0A20202020202020206C657420';
wwv_flow_imp.g_varchar2_table(137) := '746F74616C486F72697A6F6E74616C506F736974696F6E203D20303B0A0A20202020202020202F2F2043616C63756C6174652074686520746F74616C20686F72697A6F6E74616C20706F736974696F6E2073756D206F6620616C6C2073656C6563746564';
wwv_flow_imp.g_varchar2_table(138) := '20646976732E0A2020202020202020666F722028636F6E737420646976206F662073656C65637465644469767329207B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69';
wwv_flow_imp.g_varchar2_table(139) := '656E745265637428293B0A202020202020202020202020746F74616C486F72697A6F6E74616C506F736974696F6E202B3D20626F756E64696E67526563742E6C6566743B0A20202020202020207D0A0A2020202020202020636F6E737420617665726167';
wwv_flow_imp.g_varchar2_table(140) := '65486F72697A6F6E74616C506F736974696F6E203D20746F74616C486F72697A6F6E74616C506F736974696F6E202F2073656C6563746564446976732E6C656E6774683B0A0A20202020202020202F2F2041646A7573742074686520226C656674222043';
wwv_flow_imp.g_varchar2_table(141) := '53532070726F7065727479206F6620656163682073656C65637465642064697620746F20616C69676E207468656D20686F72697A6F6E74616C6C792E0A2020202020202020666F722028636F6E737420646976206F662073656C65637465644469767329';
wwv_flow_imp.g_varchar2_table(142) := '207B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69656E745265637428293B0A202020202020202020202020636F6E73742063757272656E744C656674203D20626F75';
wwv_flow_imp.g_varchar2_table(143) := '6E64696E67526563742E6C6566743B0A202020202020202020202020636F6E7374206F6666736574203D2061766572616765486F72697A6F6E74616C506F736974696F6E202D2063757272656E744C6566743B0A2020202020202020202020206469762E';
wwv_flow_imp.g_varchar2_table(144) := '7374796C652E6C656674203D2060247B63757272656E744C656674202B206F66667365747D7078603B0A20202020202020207D0A202020207D20656C7365206966202861786973203D3D3D2027766572746963616C2729207B0A20202020202020206C65';
wwv_flow_imp.g_varchar2_table(145) := '7420746F74616C566572746963616C506F736974696F6E203D20303B0A0A20202020202020202F2F2043616C63756C6174652074686520746F74616C20766572746963616C20706F736974696F6E2073756D206F6620616C6C2073656C65637465642064';
wwv_flow_imp.g_varchar2_table(146) := '6976732E0A2020202020202020666F722028636F6E737420646976206F662073656C65637465644469767329207B0A202020202020202020202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69656E';
wwv_flow_imp.g_varchar2_table(147) := '745265637428293B0A202020202020202020202020746F74616C566572746963616C506F736974696F6E202B3D20626F756E64696E67526563742E746F703B0A20202020202020207D0A0A2020202020202020636F6E7374206176657261676556657274';
wwv_flow_imp.g_varchar2_table(148) := '6963616C506F736974696F6E203D20746F74616C566572746963616C506F736974696F6E202F2073656C6563746564446976732E6C656E6774683B0A0A20202020202020202F2F2041646A757374207468652022746F7022204353532070726F70657274';
wwv_flow_imp.g_varchar2_table(149) := '79206F6620656163682073656C65637465642064697620746F20616C69676E207468656D20766572746963616C6C792E0A2020202020202020666F722028636F6E737420646976206F662073656C65637465644469767329207B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(150) := '202020636F6E737420626F756E64696E6752656374203D206469762E676574426F756E64696E67436C69656E745265637428293B0A202020202020202020202020636F6E73742063757272656E74546F70203D20626F756E64696E67526563742E746F70';
wwv_flow_imp.g_varchar2_table(151) := '3B0A202020202020202020202020636F6E7374206F6666736574203D2061766572616765566572746963616C506F736974696F6E202D2063757272656E74546F703B0A2020202020202020202020206469762E7374796C652E746F70203D2060247B6375';
wwv_flow_imp.g_varchar2_table(152) := '7272656E74546F70202B206F66667365747D7078603B0A20202020202020207D0A202020207D20656C7365207B0A2020202020202020636F6E736F6C652E6572726F722827496E76616C6964206178697320706172616D657465722E20506C6561736520';
wwv_flow_imp.g_varchar2_table(153) := '7573652022686F72697A6F6E74616C22206F722022766572746963616C222E27293B0A202020207D0A7D0A0A2F2A2A0A202A204D6F76657320616C6C2073656C65637465642064697673207769746820636C617373202273656C65637465642220626173';
wwv_flow_imp.g_varchar2_table(154) := '6564206F6E2074686520647261672064697374616E6365206F66207468652064726167676564206469762E0A202A2F0A66756E6374696F6E206D6F766553656C6563746564446976734F6E447261672829207B0A20202020636F6E73742073656C656374';
wwv_flow_imp.g_varchar2_table(155) := '656444697673203D20646F63756D656E742E717565727953656C6563746F72416C6C28272E73656C656374656427293B0A0A202020206C657420696E697469616C582C20696E697469616C592C20647261676765644469763B0A0A202020202F2A2A0A20';
wwv_flow_imp.g_varchar2_table(156) := '202020202A2040706172616D207B4D6F7573654576656E747D206576656E74202D205468652064726167207374617274206576656E742E0A20202020202A2F0A2020202066756E6374696F6E2068616E646C65447261675374617274286576656E742920';
wwv_flow_imp.g_varchar2_table(157) := '7B0A202020202020202064726167676564446976203D206576656E742E7461726765743B0A2020202020202020696E697469616C58203D206576656E742E636C69656E74583B0A2020202020202020696E697469616C59203D206576656E742E636C6965';
wwv_flow_imp.g_varchar2_table(158) := '6E74593B0A0A20202020202020202F2F20416464206576656E74206C697374656E65727320746F2068616E646C6520746865206472616767696E6720616E6420656E64206F66206472616767696E6720666F7220616C6C2073656C656374656420646976';
wwv_flow_imp.g_varchar2_table(159) := '732E0A2020202020202020646F63756D656E742E6164644576656E744C697374656E657228276D6F7573656D6F7665272C2068616E646C6544726167293B0A2020202020202020646F63756D656E742E6164644576656E744C697374656E657228276D6F';
wwv_flow_imp.g_varchar2_table(160) := '7573657570272C2068616E646C6544726167456E64293B0A202020207D0A0A202020202F2A2A0A20202020202A2040706172616D207B4D6F7573654576656E747D206576656E74202D205468652064726167206576656E742E0A20202020202A2F0A2020';
wwv_flow_imp.g_varchar2_table(161) := '202066756E6374696F6E2068616E646C6544726167286576656E7429207B0A2020202020202020696620282164726167676564446976292072657475726E3B0A0A20202020202020202F2F2043616C63756C617465207468652064697374616E63652074';
wwv_flow_imp.g_varchar2_table(162) := '686520647261676765642064697620686173206D6F7665642E0A2020202020202020636F6E73742064656C746158203D206576656E742E636C69656E7458202D20696E697469616C583B0A2020202020202020636F6E73742064656C746159203D206576';
wwv_flow_imp.g_varchar2_table(163) := '656E742E636C69656E7459202D20696E697469616C593B0A0A20202020202020202F2F204D6F766520616C6C2073656C65637465642064697673206261736564206F6E2074686520647261672064697374616E63652E0A2020202020202020666F722028';
wwv_flow_imp.g_varchar2_table(164) := '636F6E737420646976206F662073656C65637465644469767329207B0A2020202020202020202020206966202864697620213D3D2064726167676564446976202626206469762E636C6173734C6973742E636F6E7461696E73282773656C656374656427';
wwv_flow_imp.g_varchar2_table(165) := '2929207B0A202020202020202020202020202020202F2F2041646A7573742074686520646976277320706F736974696F6E206279207468652073616D6520616D6F756E74206173207468652064726167676564206469762E0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(166) := '20202020206469762E7374796C652E6C656674203D2060247B7061727365466C6F6174286469762E7374796C652E6C65667429202B2064656C7461587D7078603B0A202020202020202020202020202020206469762E7374796C652E746F70203D206024';
wwv_flow_imp.g_varchar2_table(167) := '7B7061727365466C6F6174286469762E7374796C652E746F7029202B2064656C7461597D7078603B0A2020202020202020202020207D0A20202020202020207D0A0A20202020202020202F2F205570646174652074686520696E697469616C20706F7369';
wwv_flow_imp.g_varchar2_table(168) := '74696F6E20666F7220746865206E6578742064726167206576656E742E0A2020202020202020696E697469616C58203D206576656E742E636C69656E74583B0A2020202020202020696E697469616C59203D206576656E742E636C69656E74593B0A2020';
wwv_flow_imp.g_varchar2_table(169) := '20207D0A0A202020202F2A2A0A20202020202A2040706172616D207B4D6F7573654576656E747D206576656E74202D2054686520656E64206F66207468652064726167206576656E742E0A20202020202A2F0A2020202066756E6374696F6E2068616E64';
wwv_flow_imp.g_varchar2_table(170) := '6C6544726167456E64286576656E7429207B0A20202020202020202F2F2052656D6F7665206576656E74206C697374656E657273207768656E207468652064726167206973206F7665722E0A2020202020202020646F63756D656E742E72656D6F766545';
wwv_flow_imp.g_varchar2_table(171) := '76656E744C697374656E657228276D6F7573656D6F7665272C2068616E646C6544726167293B0A2020202020202020646F63756D656E742E72656D6F76654576656E744C697374656E657228276D6F7573657570272C2068616E646C6544726167456E64';
wwv_flow_imp.g_varchar2_table(172) := '293B0A202020202020202064726167676564446976203D206E756C6C3B0A202020207D0A0A202020202F2F20416464206576656E74206C697374656E65727320746F20737461727420746865206472616767696E6720666F7220616C6C2073656C656374';
wwv_flow_imp.g_varchar2_table(173) := '656420646976732E0A20202020666F722028636F6E737420646976206F662073656C65637465644469767329207B0A20202020202020206469762E6164644576656E744C697374656E657228276D6F757365646F776E272C2068616E646C654472616753';
wwv_flow_imp.g_varchar2_table(174) := '74617274293B0A202020207D0A7D0A0A66756E6374696F6E20636F7079416E6450617374654469762829207B0A2020202076617220616C6C53656C6563746564203D2041727261792E66726F6D282428272E73656C65637465642729293B0A2020202064';
wwv_flow_imp.g_varchar2_table(175) := '6573656C656374416C6C28293B0A20202020616C6C53656C65637465642E666F724561636828656C656D656E74203D3E207B0A0A20202020202020202F2F636F6E7374206F726967696E616C446976203D20646F63756D656E742E676574456C656D656E';
wwv_flow_imp.g_varchar2_table(176) := '7442794964286964293B0A0A20202020202020202F2F20436C6F6E6520746865206F726967696E616C204449560A2020202020202020636F6E7374206E6577446976203D20656C656D656E742E636C6F6E654E6F64652874727565293B0A0A2020202020';
wwv_flow_imp.g_varchar2_table(177) := '2020202F2F2041646420746865202273656C65637465642220636C61737320746F20746865206E6577204449560A20202020202020206E65774469762E636C6173734C6973742E616464282773656C656374656427293B0A202020202020202076617220';
wwv_flow_imp.g_varchar2_table(178) := '6E65774964203D206D616B65696428293B0A20202020202020206E65774469762E6964203D206E657749643B0A0A20202020202020202F2F20496E7365727420746865206E65772044495620726967687420616674657220746865206F726967696E616C';
wwv_flow_imp.g_varchar2_table(179) := '204449560A20202020202020202428272364726F707061626C6527292E617070656E64286E6577446976293B0A202020202020202024286E6577446976292E647261676761626C6528293B0A202020202020202024286E6577446976292E62696E642827';
wwv_flow_imp.g_varchar2_table(180) := '6472616773746F70272C2066756E6374696F6E202829207B2073656C656374287468697329207D293B0A202020207D293B0A0A7D0A0A66756E6374696F6E2064656C65746553656C65637465642829207B0A202020202428272E73656C65637465642729';
wwv_flow_imp.g_varchar2_table(181) := '2E72656D6F766528293B0A7D0A0A66756E6374696F6E20726F7461746553656C65637465642829207B0A2020202076617220616C6C53656C6563746564203D202428272E73656C656374656427293B0A20202020666F7220286C657420696E646578203D';
wwv_flow_imp.g_varchar2_table(182) := '20303B20696E646578203C20616C6C53656C65637465642E6C656E6774683B20696E6465782B2B29207B0A2020202020202020636F6E737420656C656D656E74203D20616C6C53656C65637465645B696E6465785D3B0A20202020202020207661722072';
wwv_flow_imp.g_varchar2_table(183) := '6F746174654279446567203D2034353B0A20202020202020207661722063757272656E74446567203D202428656C656D656E74292E6373732822726F7461746522293B0A20202020202020206966202863757272656E74446567203D3D20276E6F6E6527';
wwv_flow_imp.g_varchar2_table(184) := '29207B0A2020202020202020202020202428656C656D656E74292E6373732822726F74617465222C20726F746174654279446567202B202264656722293B0A20202020202020207D20656C7365207B0A20202020202020202020202063757272656E7444';
wwv_flow_imp.g_varchar2_table(185) := '6567203D2063757272656E744465672E6D61746368282F5C642B2F295B305D3B0A20202020202020202020202063757272656E744465672E746F537472696E6728293B0A202020202020202020202020766172206E6577446567203D204E756D62657228';
wwv_flow_imp.g_varchar2_table(186) := '63757272656E7444656729202B204E756D62657228726F746174654279446567293B0A2020202020202020202020202428656C656D656E74292E6373732822726F74617465222C206E6577446567202B202264656722293B0A20202020202020207D0A20';
wwv_flow_imp.g_varchar2_table(187) := '2020207D0A0A7D0A70726570617265456469746F7228293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(6014460738967694)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
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
wwv_flow_imp.g_varchar2_table(17) := '686F7722293B0A7D0A2F2F200A73686F774772696428293B0A737769746368547970652831293B0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(6014841542967708)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_file_name=>'control-functions.js'
,p_mime_type=>'application/javascript'
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
wwv_flow_imp.g_varchar2_table(34) := '0A7D0A0A2E64726F7061626C652D7A6F6E652D626F6479207B0A20202020706F736974696F6E3A2072656C61746976653B0A202020206D617267696E2D746F703A203870783B0A202020203B0A7D0A2E742D546162732D6974656D7B0A20202020637572';
wwv_flow_imp.g_varchar2_table(35) := '736F723A20706F696E7465722021696D706F7274616E743B0A7D0A2E742D546162732D6C696E6B7B0A20202020637572736F723A20706F696E7465722021696D706F7274616E743B0A7D0A236D617053657474696E677344726F70646F776E203E206469';
wwv_flow_imp.g_varchar2_table(36) := '76203E206469763A6E74682D6368696C64283129203E206C6162656C7B0A202020206D617267696E2D72696768743A203570783B0A7D0A2E677269642D66756C6C2D7370616E7B0A2020202077696474683A20313030252021696D706F7274616E743B0A';
wwv_flow_imp.g_varchar2_table(37) := '20202020666C6F61743A206C6566743B0A7D0A2E636F6D706F6E656E74203E2074657874617265617B0A2020202077696474683A203930253B0A202020206865696768743A203930253B0A20202020746578742D616C69676E3A2072696768743B0A7D0A';
wwv_flow_imp.g_varchar2_table(38) := '2E72656D6F7665203E2074657874617265617B0A2020202077696474683A203930253B0A202020206865696768743A203930253B0A20202020746578742D616C69676E3A2072696768743B0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(6016410957000121)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_file_name=>'global.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220726567696F6E3D2428222364726177696E672D706C7567696E22292C616A61786964656E7469666965723D726567696F6E2E646174612822616A61782D6964656E74696669657222292C6973466972737442617463683D313B66756E6374696F';
wwv_flow_imp.g_varchar2_table(2) := '6E2073656E64546F4170657828652C6E297B72657475726E206E65772050726F6D697365282828612C73293D3E7B617065782E7365727665722E706C7567696E28616A61786964656E7469666965722C7B7830313A4A534F4E2E737472696E6769667928';
wwv_flow_imp.g_varchar2_table(3) := '65292C7830323A6973466972737442617463687D2C7B737563636573733A66756E6374696F6E2865297B636F6E736F6C652E6C6F672865292C6E2626617065782E6D6573736167652E73686F775061676553756363657373282244726177696E67206461';
wwv_flow_imp.g_varchar2_table(4) := '746120736176656420746F20636F6C6C656374696F6E22292C6973466972737442617463683D302C612865297D2C6572726F723A66756E6374696F6E28652C6E2C61297B636F6E736F6C652E6C6F672861292C732861297D2C64617461547970653A226A';
wwv_flow_imp.g_varchar2_table(5) := '736F6E222C6173796E633A21307D297D29297D6173796E632066756E6374696F6E207465737450726F6365737328297B76617220653D73617665546F4A736F6E28292C6E3D4A534F4E2E70617273652865292C613D303B6177616974206173796E632066';
wwv_flow_imp.g_varchar2_table(6) := '756E6374696F6E28297B636F6E736F6C652E6C6F672822536176696E67206461746122293B76617220653D7B7D3B666F7228636F6E7374207320696E206E296966286E2E6861734F776E50726F7065727479287329297B636F6E737420693D6E5B735D3B';
wwv_flow_imp.g_varchar2_table(7) := '696628655B735D3D692C282B2B612531303D3D307C7C613D3D3D4F626A6563742E6B657973286E292E6C656E6774682926262861776169742073656E64546F4170657828652C613D3D3D4F626A6563742E6B657973286E292E6C656E677468292C653D7B';
wwv_flow_imp.g_varchar2_table(8) := '7D2C613D3D3D4F626A6563742E6B657973286E292E6C656E6774682929627265616B7D7D28297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(6077613041092381)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_file_name=>'plugin-ajax-processes.min.js'
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
wwv_flow_imp.g_varchar2_table(25) := '617265617B77696474683A3930253B6865696768743A3930253B746578742D616C69676E3A72696768747D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(7048206129039142)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_file_name=>'global.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E20726563726561746546726F6D4A736F6E2865297B636F6E736F6C652E6C6F672822726563726561746546726F6D4A736F6E22293B76617220743D2428222E6A736F6E2D646174612D636F6E7461696E65727322293B636F6E736F6C';
wwv_flow_imp.g_varchar2_table(2) := '652E6C6F67282428222E6A736F6E2D646174612D636F6E7461696E65727322292E6C656E677468293B76617220613D227B223B666F72286C657420653D303B653C742E6C656E6774683B652B2B297B636F6E737420733D745B655D3B612B3D242873292E';
wwv_flow_imp.g_varchar2_table(3) := '6461746128226A736F6E22297D612B3D227D222C6A736F6E446174613D613B76617220733D4A534F4E2E7061727365286A736F6E44617461292C6E3D2428222364726F707061626C6522292C6F3D4F626A6563742E6B6579732873292E6C656E6774683E';
wwv_flow_imp.g_varchar2_table(4) := '303F732E64726F707061626C652E77696474683A646F63756D656E742E676574456C656D656E7442794964282277696E70757422292E76616C75652C723D4F626A6563742E6B6579732873292E6C656E6774683E303F732E64726F707061626C652E6865';
wwv_flow_imp.g_varchar2_table(5) := '696768743A646F63756D656E742E676574456C656D656E7442794964282268696E70757422292E76616C75653B666F7228766172206C20696E20653F6E2E637373287B77696474683A6F2C6865696768743A727D293A6E2E637373287B77696474683A6F';
wwv_flow_imp.g_varchar2_table(6) := '2C6865696768743A722C706F736974696F6E3A2272656C6174697665222C6261636B67726F756E64436F6C6F723A2223656565227D292C73296966282264726F707061626C6522213D3D6C297B76617220693D735B6C5D2C633D2428273C64697620636C';
wwv_flow_imp.g_varchar2_table(7) := '6173733D2272656D6F76652220272B282259223D3D3D692E617661696C61626C653F276F6E436C69636B3D22272B692E6F6E436C69636B2B2722273A2222292B223E3C2F6469763E22293B65262628633D2428273C64697620636C6173733D2272656D6F';
wwv_flow_imp.g_varchar2_table(8) := '766522206F6E436C69636B3D2273656C65637428293B223E3C2F6469763E2729292C632E637373287B77696474683A692E77696474682C6865696768743A692E6865696768742C746F703A692E746F702C6C6566743A692E6C6566742C726F746174653A';
wwv_flow_imp.g_varchar2_table(9) := '692E726F746174652C706F736974696F6E3A226162736F6C757465227D292C632E6174747228226964222C6C292C632E616464436C61737328692E636C617373292C616464496E707574416E64417661696C6162696C697479436C61737328632C69292C';
wwv_flow_imp.g_varchar2_table(10) := '61646444697669636F6E732863292C6E2E617070656E642863292C692E636C6173732E696E636C7564657328227061726B696E672D737061636522297C7C692E636C6173732E696E636C7564657328227061726B696E672D73706163652D766572746963';
wwv_flow_imp.g_varchar2_table(11) := '616C22297C7C692E636C6173732E696E636C7564657328226C6162656C22297C7C635B305D2E696E7365727441646A6163656E7448544D4C28226265666F7265656E64222C692E696E6E657248746D6C2E7265706C616365416C6C282240222C27222729';
wwv_flow_imp.g_varchar2_table(12) := '297D653F2428222E72656D6F766522292E726573697A61626C6528292E647261676761626C6528293A242822237772617070657222292E617070656E64286E293B7472797B76617220643D646F63756D656E742E717565727953656C6563746F72282223';
wwv_flow_imp.g_varchar2_table(13) := '77696E70757422292C703D646F63756D656E742E717565727953656C6563746F7228222368696E70757422293B642E76616C75653D6F2C702E76616C75653D727D63617463682865297B636F6E736F6C652E6C6F6728224E6F20696E7075747322297D24';
wwv_flow_imp.g_varchar2_table(14) := '28222E72656D6F766522292E62696E6428226472616773746F70222C2866756E6374696F6E28297B73656C6563742874686973297D29297D66756E6374696F6E2073617665546F4A736F6E28297B76617220653D7B7D2C743D2428222364726F70706162';
wwv_flow_imp.g_varchar2_table(15) := '6C6522292C613D7B77696474683A242874292E6373732822776964746822292C6865696768743A242874292E637373282268656967687422292C746F703A742E6F666673657428292E746F702C6C6566743A742E6F666673657428292E6C6566742C636C';
wwv_flow_imp.g_varchar2_table(16) := '6173733A742E617474722822636C61737322292C73706F7449643A742E69647D3B72657475726E20652E64726F707061626C653D612C2428222E72656D6F766522292E65616368282866756E6374696F6E28297B76617220743D746869732E69642C613D';
wwv_flow_imp.g_varchar2_table(17) := '7B77696474683A242874686973292E6373732822776964746822292C6865696768743A242874686973292E637373282268656967687422292C746F703A242874686973292E6373732822746F7022292C6C6566743A242874686973292E63737328226C65';
wwv_flow_imp.g_varchar2_table(18) := '667422292C636C6173733A242874686973292E617474722822636C61737322292C746578743A242874686973292E66696E642822746578746172656122292E76616C28292C726F746174653A242874686973292E6373732822726F7461746522292C7370';
wwv_flow_imp.g_varchar2_table(19) := '6F7449643A742C696E6E657248746D6C3A746869732E696E6E657248544D4C2E7265706C616365416C6C282722272C224022292E7265706C616365282F285C725C6E7C5C6E7C5C72292F676D2C2222297D3B655B745D3D617D29292C4A534F4E2E737472';
wwv_flow_imp.g_varchar2_table(20) := '696E676966792865297D66756E6374696F6E206368616E676553697A6528297B76617220653D646F63756D656E742E676574456C656D656E7442794964282277696E70757422292E76616C75652C743D646F63756D656E742E676574456C656D656E7442';
wwv_flow_imp.g_varchar2_table(21) := '794964282268696E70757422292E76616C75653B2428222364726F707061626C6522292E63737328227769647468222C65292C2428222364726F707061626C6522292E6373732822686569676874222C74297D66756E6374696F6E206D616B6569642829';
wwv_flow_imp.g_varchar2_table(22) := '7B72657475726E226E65772D69642D222B4D6174682E72616E646F6D28292E746F537472696E67283336292E73756273747228322C39297D66756E6374696F6E2070726570617265456469746F7228297B76617220653D6E756C6C3B2428222E64726167';
wwv_flow_imp.g_varchar2_table(23) := '22292E647261676761626C65287B68656C7065723A22636C6F6E65222C637572736F723A226D6F7665222C746F6C6572616E63653A22666974222C7265766572743A21307D292C2428222364726F707061626C6522292E64726F707061626C65287B6163';
wwv_flow_imp.g_varchar2_table(24) := '636570743A222E64726167222C616374697665436C6173733A2264726F702D61726561222C64726F703A66756E6374696F6E28742C61297B6966282264726167223D3D2428612E647261676761626C65295B305D2E6964297B653D612E68656C7065722E';
wwv_flow_imp.g_varchar2_table(25) := '636C6F6E6528292C612E68656C7065722E72656D6F766528292C652E647261676761626C65287B68656C7065723A226F726967696E616C222C637572736F723A226D6F7665222C746F6C6572616E63653A22666974222C64726F703A66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(26) := '28652C74297B2428742E647261676761626C65292E72656D6F766528297D2C647261673A66756E6374696F6E28652C74297B742E706F736974696F6E7D2C677269643A5B312C315D7D292C652E726573697A61626C65287B677269643A5B312C315D7D29';
wwv_flow_imp.g_varchar2_table(27) := '3B76617220733D6D616B65696428293B696628652E6174747228226964222C73292C652E616464436C617373282272656D6F766522292C652E72656D6F7665436C61737328226472616722292C28652E686173436C61737328227061726B696E672D7370';
wwv_flow_imp.g_varchar2_table(28) := '61636522297C7C652E686173436C61737328227061726B696E672D73706163652D766572746963616C222929262621652E66696E6428222E69642D696E70757422292E6C656E677468297B766172206E3D2428273C746578746172656120747970653D22';
wwv_flow_imp.g_varchar2_table(29) := '746578742220706C616365686F6C6465723D22456E74657220746578742220636C6173733D2269642D696E707574222F3E27293B652E617070656E64286E297D652E617070656E64546F28222364726F707061626C6522292C2428222E64656C65746522';
wwv_flow_imp.g_varchar2_table(30) := '292E6F6E2822636C69636B222C2866756E6374696F6E28297B242874686973292E706172656E7428292E706172656E7428227370616E22292E72656D6F766528297D29292C2428222E64656C65746522292E706172656E7428292E706172656E74282273';
wwv_flow_imp.g_varchar2_table(31) := '70616E22292E64626C636C69636B282866756E6374696F6E28297B242874686973292E72656D6F766528297D29293B766172206F3D4E756D62657228655B305D2E6F66667365744C656674292C723D4E756D62657228655B305D2E6F6666736574546F70';
wwv_flow_imp.g_varchar2_table(32) := '293B652E6373732822706F736974696F6E222C226162736F6C75746522293B766172206C3D2428222364726177696E672D706C7567696E22292E706172656E7428292E63737328226D617267696E4C65667422292E7265706C61636528227078222C2222';
wwv_flow_imp.g_varchar2_table(33) := '292C693D2428222364726177696E672D706C7567696E22292E706172656E7428292C633D28242869295B305D2E676574426F756E64696E67436C69656E745265637428292E746F702C2428222E64726F70646F776E22292E6461746128226C6566744D61';
wwv_flow_imp.g_varchar2_table(34) := '7267696E2229292C643D2428222E64726F70646F776E22292E646174612822746F704D617267696E22293B652E63737328226C656674222C6F2D6C2B63292C652E6373732822746F70222C722D64292C652E62696E6428226472616773746F70222C2866';
wwv_flow_imp.g_varchar2_table(35) := '756E6374696F6E28297B73656C6563742874686973297D29297D7D7D292C2428222372656D6F76652D6472616722292E64726F707061626C65287B64726F703A66756E6374696F6E28652C74297B2428742E647261676761626C65292E72656D6F766528';
wwv_flow_imp.g_varchar2_table(36) := '297D2C686F766572436C6173733A2272656D6F76652D647261672D686F766572222C6163636570743A222E72656D6F7665227D293B636F6E737420743D646F63756D656E742E717565727953656C6563746F7228222377696E70757422292C613D646F63';
wwv_flow_imp.g_varchar2_table(37) := '756D656E742E717565727953656C6563746F7228222368696E70757422293B7472797B742E6164644576656E744C697374656E657228226368616E6765222C28653D3E7B6368616E676553697A6528297D29292C612E6164644576656E744C697374656E';
wwv_flow_imp.g_varchar2_table(38) := '657228226368616E6765222C28653D3E7B6368616E676553697A6528297D29297D63617463682865297B7D7D66756E6374696F6E2061646444697669636F6E732865297B76617220743D7B226172726F772D6C656674223A2266612066612D6172726F77';
wwv_flow_imp.g_varchar2_table(39) := '2D6C656674222C226172726F772D7269676874223A2266612066612D6172726F772D7269676874222C226172726F772D7570223A2266612066612D6172726F772D7570222C226172726F772D646F776E223A2266612066612D6172726F772D646F776E22';
wwv_flow_imp.g_varchar2_table(40) := '2C226172726F772D696E2D65617374223A2266612066612D626F782D6172726F772D696E2D65617374222C227061726B696E672D73706163652D70617261706C65676963223A2266612066612D776865656C6368616972227D3B72657475726E20652E65';
wwv_flow_imp.g_varchar2_table(41) := '616368282866756E6374696F6E28297B666F7228766172206520696E207429696628242874686973292E686173436C617373286529297B76617220613D2428273C6920636C6173733D22272B745B655D2B27223E3C2F693E27293B242874686973292E61';
wwv_flow_imp.g_varchar2_table(42) := '7070656E642861293B627265616B7D7D29292C657D66756E6374696F6E20616464496E707574416E64417661696C6162696C697479436C61737328652C74297B696628652E686173436C61737328227061726B696E672D737061636522297C7C652E6861';
wwv_flow_imp.g_varchar2_table(43) := '73436C61737328227061726B696E672D73706163652D766572746963616C22297C7C652E686173436C61737328226C6162656C2229297B76617220613D2428273C746578746172656120747970653D22746578742220706C616365686F6C6465723D2222';
wwv_flow_imp.g_varchar2_table(44) := '20636C6173733D2269642D696E707574222F3E27293B612E76616C28742E74657874292C652E617070656E642861293B76617220733D7B593A22617661696C61626C65222C4E3A226E6F742D617661696C61626C65222C523A227265736572766564227D';
wwv_flow_imp.g_varchar2_table(45) := '5B742E617661696C61626C655D7C7C22223B652E686173436C61737328226C6162656C22297C7C652E616464436C6173732873297D7D66756E6374696F6E20726F7461746528652C74297B76617220613D747C7C31302C733D242865292E706172656E74';
wwv_flow_imp.g_varchar2_table(46) := '28292C6E3D732E6373732822726F7461746522293B696628226E6F6E65223D3D6E29732E6373732822726F74617465222C612B2264656722293B656C73657B286E3D6E2E6D61746368282F5C642B2F295B305D292E746F537472696E6728293B76617220';
wwv_flow_imp.g_varchar2_table(47) := '6F3D4E756D626572286E292B4E756D6265722861293B732E6373732822726F74617465222C6F2B2264656722297D7D66756E6374696F6E2073656C6563742865297B696628652976617220743D653B656C736520743D746869732E6576656E742E746172';
wwv_flow_imp.g_varchar2_table(48) := '6765743B242874292E686173436C617373282275692D726573697A61626C652D68616E646C6522297C7C28242874292E686173436C6173732822636F6D706F6E656E7422297C7C242874292E686173436C617373282269642D696E70757422297C7C2428';
wwv_flow_imp.g_varchar2_table(49) := '74292E686173436C617373282269676E6F72652D73656C656374656422297C7C28743D242874292E636C6F7365737428222E636F6D706F6E656E742229292C242874292E686173436C617373282273656C656374656422293F242874292E72656D6F7665';
wwv_flow_imp.g_varchar2_table(50) := '436C617373282273656C656374656422293A242874292E686173436C6173732822636F6D706F6E656E7422293F242874292E616464436C617373282273656C656374656422293A242874292E686173436C6173732822636F6D706F6E656E7422297C7C24';
wwv_flow_imp.g_varchar2_table(51) := '2874292E66696E6428222E636F6D706F6E656E7422292E616464436C617373282273656C65637465642229297D66756E6374696F6E20646573656C656374416C6C28297B41727261792E66726F6D282428222E73656C65637465642229292E666F724561';
wwv_flow_imp.g_varchar2_table(52) := '63682828653D3E7B242865292E72656D6F7665436C617373282273656C656374656422297D29297D66756E6374696F6E20616C69676E53656C6563746564446976732865297B636F6E737420743D646F63756D656E742E717565727953656C6563746F72';
wwv_flow_imp.g_varchar2_table(53) := '416C6C28222E73656C656374656422293B69662830213D3D742E6C656E6774682969662822686F72697A6F6E74616C223D3D3D65297B6C657420653D303B666F7228636F6E73742061206F662074297B652B3D612E676574426F756E64696E67436C6965';
wwv_flow_imp.g_varchar2_table(54) := '6E745265637428292E6C6566747D636F6E737420613D652F742E6C656E6774683B666F7228636F6E73742065206F662074297B636F6E737420743D652E676574426F756E64696E67436C69656E745265637428292E6C6566742C733D612D743B652E7374';
wwv_flow_imp.g_varchar2_table(55) := '796C652E6C6566743D60247B742B737D7078607D7D656C73652069662822766572746963616C223D3D3D65297B6C657420653D303B666F7228636F6E73742061206F662074297B652B3D612E676574426F756E64696E67436C69656E745265637428292E';
wwv_flow_imp.g_varchar2_table(56) := '746F707D636F6E737420613D652F742E6C656E6774683B666F7228636F6E73742065206F662074297B636F6E737420743D652E676574426F756E64696E67436C69656E745265637428292E746F702C733D612D743B652E7374796C652E746F703D60247B';
wwv_flow_imp.g_varchar2_table(57) := '742B737D7078607D7D656C736520636F6E736F6C652E6572726F722827496E76616C6964206178697320706172616D657465722E20506C65617365207573652022686F72697A6F6E74616C22206F722022766572746963616C222E27297D66756E637469';
wwv_flow_imp.g_varchar2_table(58) := '6F6E206D6F766553656C6563746564446976734F6E4472616728297B636F6E737420653D646F63756D656E742E717565727953656C6563746F72416C6C28222E73656C656374656422293B6C657420742C612C733B66756E6374696F6E206E2865297B73';
wwv_flow_imp.g_varchar2_table(59) := '3D652E7461726765742C743D652E636C69656E74582C613D652E636C69656E74592C646F63756D656E742E6164644576656E744C697374656E657228226D6F7573656D6F7665222C6F292C646F63756D656E742E6164644576656E744C697374656E6572';
wwv_flow_imp.g_varchar2_table(60) := '28226D6F7573657570222C72297D66756E6374696F6E206F286E297B69662821732972657475726E3B636F6E7374206F3D6E2E636C69656E74582D742C723D6E2E636C69656E74592D613B666F7228636F6E73742074206F6620652974213D3D73262674';
wwv_flow_imp.g_varchar2_table(61) := '2E636C6173734C6973742E636F6E7461696E73282273656C65637465642229262628742E7374796C652E6C6566743D60247B7061727365466C6F617428742E7374796C652E6C656674292B6F7D7078602C742E7374796C652E746F703D60247B70617273';
wwv_flow_imp.g_varchar2_table(62) := '65466C6F617428742E7374796C652E746F70292B727D707860293B743D6E2E636C69656E74582C613D6E2E636C69656E74597D66756E6374696F6E20722865297B646F63756D656E742E72656D6F76654576656E744C697374656E657228226D6F757365';
wwv_flow_imp.g_varchar2_table(63) := '6D6F7665222C6F292C646F63756D656E742E72656D6F76654576656E744C697374656E657228226D6F7573657570222C72292C733D6E756C6C7D666F7228636F6E73742074206F66206529742E6164644576656E744C697374656E657228226D6F757365';
wwv_flow_imp.g_varchar2_table(64) := '646F776E222C6E297D66756E6374696F6E20636F7079416E64506173746544697628297B76617220653D41727261792E66726F6D282428222E73656C65637465642229293B646573656C656374416C6C28292C652E666F72456163682828653D3E7B636F';
wwv_flow_imp.g_varchar2_table(65) := '6E737420743D652E636C6F6E654E6F6465282130293B742E636C6173734C6973742E616464282273656C656374656422293B76617220613D6D616B65696428293B742E69643D612C2428222364726F707061626C6522292E617070656E642874292C2428';
wwv_flow_imp.g_varchar2_table(66) := '74292E647261676761626C6528292C242874292E62696E6428226472616773746F70222C2866756E6374696F6E28297B73656C6563742874686973297D29297D29297D66756E6374696F6E2064656C65746553656C656374656428297B2428222E73656C';
wwv_flow_imp.g_varchar2_table(67) := '656374656422292E72656D6F766528297D66756E6374696F6E20726F7461746553656C656374656428297B76617220653D2428222E73656C656374656422293B666F72286C657420733D303B733C652E6C656E6774683B732B2B297B636F6E7374206E3D';
wwv_flow_imp.g_varchar2_table(68) := '655B735D3B76617220743D24286E292E6373732822726F7461746522293B696628226E6F6E65223D3D742924286E292E6373732822726F74617465222C22343564656722293B656C73657B28743D742E6D61746368282F5C642B2F295B305D292E746F53';
wwv_flow_imp.g_varchar2_table(69) := '7472696E6728293B76617220613D4E756D6265722874292B4E756D626572283435293B24286E292E6373732822726F74617465222C612B2264656722297D7D7D70726570617265456469746F7228293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(7049527845054641)
,p_plugin_id=>wwv_flow_imp.id(6011114714941373)
,p_file_name=>'map.min.js'
,p_mime_type=>'text/javascript'
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
