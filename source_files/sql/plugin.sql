FUNCTION resize (
  pi_size in varchar2, 
  pi_percent in number default 1
) return varchar2
is
    l_clob clob;
begin
    return 
            floor(
                to_number(replace(replace(pi_size,'.',','),'px','')) * pi_percent
                ) ||'px';
end resize;
----
FUNCTION render_region(p_region              IN apex_plugin.t_region,
                       p_plugin              IN apex_plugin.t_plugin,
                       p_is_printer_friendly IN BOOLEAN)
  RETURN apex_plugin.t_region_render_result IS
  -- plugin attributes
  l_result   apex_plugin.t_region_render_result;
  l_attr_01  p_region.attribute_01%TYPE := p_region.attribute_01;
  l_editable p_region.attribute_02%TYPE := p_region.attribute_02;
  l_resize   p_region.attribute_03%TYPE := replace(NVL(p_region.attribute_03,1),'.',',');
  -- other vars
  l_region_id       VARCHAR2(4000 char);
  l_ajax_identifier clob;
  v_data            apex_plugin_util.t_column_value_list;
  v_json            clob;
  v_json_enclave    clob;
  v_object_id       varchar2(4000 char);
  --
BEGIN
  -- Debug
  IF apex_application.g_debug THEN
    apex_plugin_util.debug_region(p_plugin => p_plugin,
                                  p_region => p_region);
  END IF;
  -- set vars
  l_region_id := apex_escape.html_attribute(p_region.static_id ||
                                            '_myregion');
  l_ajax_identifier := apex_plugin.get_ajax_identifier;                                          
  -- escape input
  l_attr_01 := apex_escape.html(l_attr_01);
  --
/*---------------------
    RENDER START
----------------------*/
  sys.htp.p('<div id="drawing-plugin" data-ajax-identifier="'||l_ajax_identifier||'"' ||
            ' class="drawing-plugin-body">');
  --STYLE
  sys.htp.p('<style>');
  for component_rec in (select css from type_component)
    loop
      sys.htp.p(component_rec.css);
    end loop;
  sys.htp.p('</style>');
  --
  sys.htp.p('<div class="grid-left">');
  if l_editable = 'Y' then 
    sys.htp.p('<div class="left-side-buttons">
      <div class="dropdown">
        <button class="t-Button t-Button--primary t-Button--icon t-Button--iconLeft button-dropdown-map" 
          onclick="toggleMapSettings()" type="button" title="Map settings - on click open/hide options menu">
          <span class="t-Icon t-Icon--left fa fa-cog" aria-hidden="true"></span>
          <span class="t-Button-label">Map settings</span>
          <span class="t-Icon t-Icon--right fa fa-cog" aria-hidden="true"></span>
        </button>
        <div id="mapSettingsDropdown" class="dropdown-content">
        <div class="dropdown-inner">
          <div class="size-input">
            <label for="fname">Width:</label>
            <input type="text" id="winput" class="inputs" name="width" value="800">
          </div>
          <div class="size-input">
            <label for="fname">Height:</label>
            <input type="text" id="hinput" class="inputs" name="height" value="500">
          </div>
          <button class="t-Button" type="button" onClick="showGrid();">Show Grid</button>
        </div>
        </div>
      </div>
      <button class="t-Button" type="button" onclick="alignSelectedDivs(''vertical'');" title="Align selected elements vertically">Align Vertically</button>
      <button class="t-Button" type="button" onclick="alignSelectedDivs(''horizontal'');" title="Align selected elements horizontally">Align Horizontally</button>
      <button class="t-Button" type="button" onclick="copyAndPasteDiv();" title="Create a copy of selected elements">Clone</button>
      <button class="t-Button" type="button" onclick="rotateSelected();" title="Rotate selected elements">Rotate</button>
      <button class="t-Button" type="button" onclick="deselectAll();" title="Deselect all the elements">Deselect all</button>
      <button class="t-Button t-Button--danger" type="button" type="button" onclick="deleteSelected();" title="Delete all the selected elements">Delete selected</button>
      <button class="t-Button t-Button--success" id="save-button" type="button" onclick="testProcess();" title="Save the plan into a collection">Save</button>
    </div>');
  end if;
  sys.htp.p('<div class="droppable-scroll-parent">
    <div class="dropable-zone-body" id="droppable"></div>
    </div>
  </div>');
  --
  if l_editable = 'Y' then 
    sys.htp.p('
    <div class="grid-right">
      <div class="type-row"> 
        <div class="type-select-section">
          <ul class="t-Tabs t-Tabs--simple a-Tabs custom-tabs" role="tablist" style="white-space: nowrap; overflow-x: hidden;">
      ');
    -- Create plan types buttons
    for type_rec in (select id, name from plan_type)
    loop
      sys.htp.p('
      <li onClick="switchType('|| type_rec.id ||')" class="t-Tabs-item " role="presentation" id="'|| type_rec.id ||'">
        <a class="t-Tabs-link" role="tab" aria-selected="true"aria-controls="'|| type_rec.id ||'">
          <span>'|| type_rec.name ||'</span>
        </a>
      </li>');
    end loop;
    sys.htp.p('</ul>');
    -- Create plan type components
    for type_rec in (select id, name from plan_type)
      loop
        sys.htp.p('<div id="'||type_rec.id||'" class="components-row">');
        for component_rec in (select code from type_component where plan_type_id = type_rec.id)
        loop
          sys.htp.p(component_rec.code);
        end loop;
        sys.htp.p('</div>');
    end loop;
   sys.htp.p('</div>');
  end if;
 
 apex_javascript.add_library(p_name          => 'plugin-ajax-processes',
                            p_directory      => p_plugin.file_prefix,
                            p_version        => NULL,
                            p_skip_extension => FALSE);

/*--------------------------------------------------------
  Create json from plugin source and pass it to JS
--------------------------------------------------------*/
  v_json_enclave := '{';
  v_data := apex_plugin_util.get_data(
    p_sql_statement => p_region.source, 
    p_min_columns   => 1, 
    p_max_columns   => 30, 
    p_component_name => p_region.name,
    p_max_rows => 1000);
  
  for i in v_data.first .. v_data(1).count loop
    BEGIN
      --Adding ID in front of object
      if v_data(5)(i) like '%droppable%' then
        v_object_id := '"droppable":';
      else 
        v_object_id := '"'||NVL(v_data(8)(i),floor(dbms_random.value(1,1000)))||'":';
      end if;
      if l_editable = 'Y' then 
        l_resize := 1;
      end if;
      v_json := v_object_id ||
        json_object(
          'width' value resize(v_data(1)(i),l_resize), 
          'height' value resize(v_data(2)(i),l_resize), 
          'top' value resize(v_data(3)(i),l_resize), 
          'left' value resize(v_data(4)(i),l_resize), 
          'class' value v_data(5)(i), 
          'text' value v_data(6)(i), 
          'available' value v_data(7)(i), 
          'spot_id' value v_data(8)(i), 
          'rotate' value v_data(9)(i),
          'onClick' value v_data(10)(i),
          'innerHtml' value v_data(11)(i)
        );
      if i = 1 then 
        v_json_enclave := v_json_enclave || v_json;
      else 
        v_json_enclave := v_json_enclave || ',' || v_json;
      end if;
    EXCEPTION WHEN OTHERS THEN 
        htp.p('<div> ERROR ' || i || '</div>');
    END;
  end loop;

  v_json_enclave := v_json_enclave || '}';
  --Editable or not
  if l_editable = 'Y' then
    apex_javascript.add_onload_code (
      p_code => 'recreateFromJson('''||v_json_enclave||''',true);',
      p_key  => 'my_super_widget');
  else 
    apex_javascript.add_onload_code (
      p_code => 'recreateFromJson('''||v_json_enclave||''',false);',
      p_key  => 'my_super_widget');
  end if;
/*--------------------------------------------------------
  Plugin source END
--------------------------------------------------------*/
/*---------------------
    RENDER END
----------------------*/
  --
  RETURN l_result;
  --
END render_region;
------------------------------------------------
------------------------------------------------
FUNCTION ajax_region(p_region IN apex_plugin.t_region,
                     p_plugin IN apex_plugin.t_plugin)
  RETURN apex_plugin.t_region_ajax_result IS
  -- plugin attributes
  l_result apex_plugin.t_region_ajax_result;
  l_val clob := apex_application.g_x01;
  l_query clob;
  l_collection_name p_region.attribute_01%TYPE := p_region.attribute_01;
  --
BEGIN
  l_query := q'[
        select 
          width, height
          , top, left, class, text
          , 'Y' as available
          , spot_id
          , rotate
          , innerHtml
        from JSON_TABLE 
          (']'||l_val||q'[', '$' COLUMNS
              (NESTED path '$.*' COLUMNS
                  (
                      width varchar2 PATH '$.width',
                      height varchar2 PATH '$.height',
                      top varchar2 PATH '$.top',
                      left varchar2 PATH '$.left',
                      class varchar2 PATH '$.class',
                      text varchar2 PATH '$.text',
                      spot_id number PATH '$.spotId',
                      rotate varchar2 PATH '$.rotate',
                      innerHtml varchar2 PATH '$.innerHtml'
                  )
              )
          ) j
    ]';
    APEX_COLLECTION.CREATE_COLLECTION_FROM_QUERY (
        p_collection_name    => l_collection_name,
        p_query              => l_query,
        p_generate_md5       => NULL,
        p_truncate_if_exists => 'YES');
  commit;
  --
  apex_json.open_object;
    apex_json.write(
    p_name => 'success'
    , p_value => true
    );

    apex_json.close_object;
  RETURN l_result;
  --
END ajax_region;

/*---------------------
    AJAX END
----------------------*/