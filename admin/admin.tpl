{html_style}
#configContent li {
  display: grid;
  grid-template-columns: 220px minmax(0, 620px);
  align-items: start;
  gap: 8px 24px;
  margin: 0 0 12px;
}

#configContent .property {
  font-weight: bold;
  width: 100%;
  text-align: start;
}

#configContent .option-group {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px 18px;
}

#configContent .image-picker,
#configContent .image-search {
  width: 100%;
  box-sizing: border-box;
}

#configContent .image-picker {
  position: relative;
}

#configContent .image-search {
  padding: 8px 10px;
  cursor: pointer;
}

#configContent .image-list {
  position: absolute;
  top: 100%;
  right: 0;
  left: 0;
  display: none;
  max-height: 260px;
  overflow-y: auto;
  border: 1px solid #ccc;
  background: #fff;
  z-index: 10;
}

#configContent .image-picker.open .image-list {
  display: block;
}

#configContent .image-choice {
  display: block;
  width: 100%;
  padding: 8px 10px;
  border: 0;
  background: #fff;
  text-align: left;
  cursor: pointer;
}

#configContent .image-choice:hover,
#configContent .image-choice.selected {
  background: #eef3ff;
}

#configContent .image-choice[hidden] {
  display: none;
}

#configContent .description {
  grid-column: 2;
  margin: 0;
  color: #777;
}

#configContent .number-input {
  width: 90px;
}

@media (max-width: 700px) {
  #configContent li {
    grid-template-columns: 1fr;
  }

  #configContent .property,
  #configContent .description {
    grid-column: 1;
  }
}
{/html_style}

<div class="titrePage">
  <h2>{'Macadam, Configuration Page'|@translate}</h2>
</div>

<form method="post" class="properties" action="" name="form">
  <div id="configContent">
    <fieldset>
      <legend>{'Layout options'|@translate}</legend>
      <ul>
        <li>
          <span class="property">{'Default photo layout'|@translate}</span>
          <div class="option-group">
            <label for="default_layout_grid">
              <input type="radio" name="default_layout" value="grid"
                id="default_layout_grid"
                {if $options.default_layout == 'grid'}checked="checked"{/if}>
              {'Grid'|@translate}
            </label>
            <label for="default_layout_list">
              <input type="radio" name="default_layout" value="list"
                id="default_layout_list"
                {if $options.default_layout == 'list'}checked="checked"{/if}>
              {'List'|@translate}
            </label>
          </div>
        </li>
      </ul>
    </fieldset>

    <fieldset>
      <legend>{'Appearance options'|@translate}</legend>
      <ul>
        <li>
          <span class="property">{'Color scheme'|@translate}</span>
          <div class="option-group">
            <label for="color_scheme_blue">
              <input type="radio" name="color_scheme" value="blue"
                id="color_scheme_blue"
                {if $options.color_scheme == 'blue'}checked="checked"{/if}>
              {'Blue'|@translate}
            </label>
            <label for="color_scheme_green">
              <input type="radio" name="color_scheme" value="green"
                id="color_scheme_green"
                {if $options.color_scheme == 'green'}checked="checked"{/if}>
              {'Green'|@translate}
            </label>
            <label for="color_scheme_orange">
              <input type="radio" name="color_scheme" value="orange"
                id="color_scheme_orange"
                {if $options.color_scheme == 'orange'}checked="checked"{/if}>
              {'Orange'|@translate}
            </label>
            <label for="color_scheme_pink">
              <input type="radio" name="color_scheme" value="pink"
                id="color_scheme_pink"
                {if $options.color_scheme == 'pink'}checked="checked"{/if}>
              {'Pink'|@translate}
            </label>
            <label for="color_scheme_bluenight">
              <input type="radio" name="color_scheme" value="bluenight"
                id="color_scheme_bluenight"
                {if $options.color_scheme == 'bluenight'}checked="checked"{/if}>
              {'Blue Night'|@translate}
            </label>
            <label for="color_scheme_grayscale">
              <input type="radio" name="color_scheme" value="grayscale"
                id="color_scheme_grayscale"
                {if $options.color_scheme == 'grayscale'}checked="checked"{/if}>
              {'Grayscale'|@translate}
            </label>
          </div>
        </li>
      </ul>
    </fieldset>

    <fieldset>
      <legend>{'Header options'|@translate}</legend>
      <ul>
        <li>
          <span class="property">{'Banner height'|@translate}</span>
          <div class="option-group">
            <label for="header_height_mode_pixels">
              <input type="radio" name="header_height_mode" value="pixels"
                id="header_height_mode_pixels"
                {if $options.header_height_mode == 'pixels'}checked="checked"{/if}>
              {'Pixels'|@translate}
            </label>
            <input type="number" class="number-input" name="header_height" id="header_height"
              min="100" max="2000" step="1" value="{$options.header_height}"
              {if $options.header_height_mode != 'pixels'}disabled="disabled"{/if}>
            <span class="field-help">px</span>
            <label for="header_height_mode_fullscreen">
              <input type="radio" name="header_height_mode" value="fullscreen"
                id="header_height_mode_fullscreen"
                {if $options.header_height_mode == 'fullscreen'}checked="checked"{/if}>
              {'Full screen'|@translate}
            </label>
          </div>
        </li>
        <li>
          <span class="property">{'Header background'|@translate}</span>
          <div class="image-picker">
            <input type="hidden" name="header_image_id" id="header_image_id"
              value="{$options.header_image_id}">
            <input type="text" class="image-search" id="header-image-search"
              placeholder="{'Search an image'|@translate}"
              aria-label="{'Search an image'|@translate}">
            <div class="image-list" id="header-image-list">
              <button type="button" class="image-choice{if $options.header_image_id == 0} selected{/if}"
                data-image-id="0">
                {'Use the default gradient'|@translate}
              </button>
              {foreach from=$header_images item=image}
                <button type="button"
                  class="image-choice{if $options.header_image_id == $image.id} selected{/if}"
                  data-image-id="{$image.id}"
                  data-image-name="{$image.name|default:$image.path|escape:'html'}">
                  #{$image.id} - {$image.name|default:$image.path|escape:'html'}
                </button>
              {/foreach}
            </div>
          </div>
          <p class="description">{'Choose an image from the gallery to use as the header background.'|@translate}</p>
        </li>
      </ul>
    </fieldset>

    <fieldset>
      <legend>{'Album photo information'|@translate}</legend>
      <ul>
        <li>
          <span class="property">{'Information below photo names'|@translate}</span>
          <div class="option-group">
            <label for="thumbnail_metadata_format">
              <input type="checkbox" name="thumbnail_metadata[]" value="format"
                id="thumbnail_metadata_format"
                {if in_array('format', $options.thumbnail_metadata)}checked="checked"{/if}>
              {'Format'|@translate}
            </label>
            <label for="thumbnail_metadata_filesize">
              <input type="checkbox" name="thumbnail_metadata[]" value="filesize"
                id="thumbnail_metadata_filesize"
                {if in_array('filesize', $options.thumbnail_metadata)}checked="checked"{/if}>
              {'File size'|@translate}
            </label>
            <label for="thumbnail_metadata_date_creation">
              <input type="checkbox" name="thumbnail_metadata[]" value="date_creation"
                id="thumbnail_metadata_date_creation"
                {if in_array('date_creation', $options.thumbnail_metadata)}checked="checked"{/if}>
              {'Creation date'|@translate}
            </label>
            <label for="thumbnail_metadata_author">
              <input type="checkbox" name="thumbnail_metadata[]" value="author"
                id="thumbnail_metadata_author"
                {if in_array('author', $options.thumbnail_metadata)}checked="checked"{/if}>
              {'Author'|@translate}
            </label>
            <label for="thumbnail_metadata_date_available">
              <input type="checkbox" name="thumbnail_metadata[]" value="date_available"
                id="thumbnail_metadata_date_available"
                {if in_array('date_available', $options.thumbnail_metadata)}checked="checked"{/if}>
              {'Publication date'|@translate}
            </label>
          </div>
          <p class="description">{'Choose the information displayed below photo names in albums.'|@translate}</p>
        </li>
      </ul>
    </fieldset>
  </div>
  <p>
    <input class="submit" type="submit" value="{'Submit'|@translate}" name="submit_macadam">
  </p>
</form>

{combine_script id='macadam.admin' load='footer' path='themes/macadam/js/admin.js'}
