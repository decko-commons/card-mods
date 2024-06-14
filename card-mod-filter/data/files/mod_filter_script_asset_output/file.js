// compact_filter.js.coffee
(function() {
  decko.compactFilter = function(el) {
    var closest_widget;
    closest_widget = $(el).closest("._compact-filter");
    this.widget = closest_widget.length ? closest_widget : $(el).closest("._filtered-content").find("._compact-filter");
    this.form = this.widget.find("._compact-filter-form");
    this.quickFilter = this.widget.find("._quick-filter");
    this.activeContainer = this.widget.find("._filter-container");
    this.dropdown = this.widget.find("._add-filter-dropdown");
    this.dropdownItems = this.widget.find("._filter-category-select");
    this.showWithStatus = function(status) {
      var f;
      f = this;
      return $.each(this.dropdownItems, function() {
        var item;
        item = $(this);
        if (item.data(status)) {
          return f.activate(item.data("category"));
        }
      });
    };
    this.reset = function() {
      return this.restrict(this.form.find("._reset-filter").data("reset"));
    };
    this.clear = function() {
      this.dropdownItems.show();
      return this.activeContainer.find(".input-group").remove();
    };
    this.activate = function(category, value) {
      this.activateField(category, value);
      return this.hideOption(category);
    };
    this.showOption = function(category) {
      this.dropdown.show();
      return this.option(category).show();
    };
    this.hideOption = function(category) {
      this.option(category).hide();
      if (this.dropdownItems.length <= this.activeFields().length) {
        return this.dropdown.hide();
      }
    };
    this.activeFields = function() {
      return this.activeContainer.find("._filter-input");
    };
    this.option = function(category) {
      return this.dropdownItems.filter("[data-category='" + category + "']");
    };
    this.findPrototype = function(category) {
      return this.widget.find("._filter-input-field-prototypes ._filter-input-" + category);
    };
    this.activateField = function(category, value) {
      var field;
      field = this.findPrototype(category).clone();
      this.fieldValue(field, value);
      this.dropdown.before(field);
      this.initField(field);
      return field.find("input, select").first().focus();
    };
    this.fieldValue = function(field, value) {
      if (typeof value === "object" && !Array.isArray(value)) {
        return this.compoundFieldValue(field, value);
      } else {
        return this.simpleFieldValue(field, value);
      }
    };
    this.simpleFieldValue = function(field, value) {
      var input;
      input = field.find("input, select");
      if (typeof value !== 'undefined') {
        return input.val(value);
      }
    };
    this.compoundFieldValue = function(field, vals) {
      var input, key, results;
      results = [];
      for (key in vals) {
        input = field.find("#filter_value_" + key);
        results.push(input.val(vals[key]));
      }
      return results;
    };
    this.removeField = function(category) {
      this.activeField(category).remove();
      return this.showOption(category);
    };
    this.initField = function(field) {
      this.initSelectField(field);
      return decko.initAutoCardPlete(field.find("input"));
    };
    this.initSelectField = function(field) {
      return decko.initSelect2(field.find("select"));
    };
    this.activeField = function(category) {
      return this.activeContainer.find("._filter-input-" + category);
    };
    this.isActive = function(category) {
      return this.activeField(category).length;
    };
    this.restrict = function(data) {
      var key;
      this.clear();
      for (key in data) {
        this.activateField(key, data[key]);
      }
      return this.update();
    };
    this.addRestrictions = function(hash) {
      var category;
      for (category in hash) {
        this.removeField(category);
        this.activate(category, hash[category]);
      }
      return this.update();
    };
    this.removeRestrictions = function(hash) {
      var category;
      for (category in hash) {
        this.removeField(category);
      }
      return this.update();
    };
    this.updateUrlBar = function() {};
    this.update = function() {
      this.form.submit();
      this.updateQuickLinks();
      return this.updateUrlBar();
    };
    this.updateIfPresent = function(category) {
      var val;
      val = this.activeField(category).find("input, select").val();
      if (val && val.length > 0) {
        return this.update();
      }
    };
    this.updateQuickLinks = function() {
      var links, widget;
      widget = this;
      links = this.quickFilter.find("._compact-filter-link");
      links.addClass("active");
      return links.each(function() {
        var key, link, opts, results;
        link = $(this);
        opts = link.data("filter");
        results = [];
        for (key in opts) {
          results.push(widget.deactivateQuickLink(link, key, opts[key]));
        }
        return results;
      });
    };
    this.deactivateQuickLink = function(link, key, value) {
      var sel;
      sel = "._filter-input-" + key;
      return $.map([this.form.find(sel + " input, " + sel + " select").val()], function(arr) {
        arr = [arr].flat();
        if ($.inArray(value, arr) > -1) {
          return link.removeClass("active");
        }
      });
    };
    return this;
  };

}).call(this);

// compact_filter_links.js.coffee
(function() {
  var filterFor, filterableData, inactiveQuickfilter, targetFilter, weirdoSelect2FilterBreaker;

  decko.slot.ready(function(slot) {
    return slot.find("._compact-filter").each(function() {
      var filter;
      if (slot[0] === $(this).slot()[0]) {
        filter = new decko.compactFilter(this);
        filter.showWithStatus("active");
        filter.updateQuickLinks();
        return filter.form.on("submit", function() {
          return filter.updateQuickLinks();
        });
      }
    });
  });

  $(window).ready(function() {
    var onchangers;
    $("body").on("click", "._filter-category-select", function(e) {
      var category, f;
      e.preventDefault();
      f = filterFor(this);
      category = $(this).data("category");
      f.activate(category);
      return f.updateIfPresent(category);
    });
    onchangers = "._compact-filter-form ._filter-input input:not(.simple-text), " + "._compact-filter-form ._filter-input select, " + "._compact-filter-form ._filter-sort";
    $("body").on("change", onchangers, function() {
      if (weirdoSelect2FilterBreaker(this)) {
        return;
      }
      return filterFor(this).update();
    });
    $("body").on("click", "._delete-filter-input", function() {
      var filter;
      filter = filterFor(this);
      filter.removeField($(this).closest("._filter-input").data("category"));
      return filter.update();
    });
    $('body').on('click', '._reset-filter', function() {
      var f;
      f = filterFor(this);
      f.reset();
      return f.update();
    });
    $('body').on('click', '._filtering ._filterable', function(e) {
      var f;
      f = targetFilter(this);
      if (f.widget.length) {
        f.restrict(filterableData(this));
        e.preventDefault();
        return e.stopPropagation();
      }
    });
    return $('body').on('click', '._compact-filter-link', function(e) {
      var f, filter_data, link;
      f = filterFor(this);
      link = $(this);
      filter_data = link.data("filter");
      if (inactiveQuickfilter(link)) {
        f.removeRestrictions(filter_data);
      } else {
        f.addRestrictions(filter_data);
      }
      e.preventDefault();
      return e.stopPropagation();
    });
  });

  filterFor = function(el) {
    return new decko.compactFilter(el);
  };

  weirdoSelect2FilterBreaker = function(el) {
    return $(el).hasClass("select2-search__field");
  };

  filterableData = function(filterable) {
    var f;
    f = $(filterable);
    return f.data("filter") || f.find("._filterable").data("filter");
  };

  targetFilter = function(filterable) {
    var selector;
    selector = $(filterable).closest("._filtering").data("filter-selector");
    return filterFor(selector || this);
  };

  inactiveQuickfilter = function(link) {
    return !link.hasClass("active") && link.closest(".quick-filter").length > 0;
  };

}).call(this);

// filter_form.js.coffee
(function() {
  var findInFilteredContent, query, removeFromQuery, resetOffCanvas, updateUrlBarWithFilter;

  decko.filter = {
    refilter: function(el) {
      var form, query, url;
      form = $(el).closest("form");
      query = form.data("query");
      url = decko.path(form.attr("action") + "?" + $.param(query));
      form.slot().slotReload(url);
      updateUrlBarWithFilter(form, query);
      return resetOffCanvas(form);
    }
  };

  $(window).ready(function() {
    $("body").on("submit", "._filter-form", function() {
      var el, query;
      el = $(this);
      query = el.serializeArray().filter(function(i) {
        return i.value;
      });
      return updateUrlBarWithFilter(el, query);
    });
    $("body").on("click", "._show-more-filter-options a", function(e) {
      var a, items;
      a = $(this);
      items = a.closest("._filter-list").find("._more-filter-option");
      if (a.text() === "show more") {
        items.show();
        a.text("show less");
      } else {
        items.hide();
        a.text("show more");
      }
      return e.preventDefault();
    });
    $("body").on("click", "._filter-closers a", function(e) {
      var link;
      link = $(this);
      removeFromQuery(link);
      decko.filter.refilter(this);
      return e.preventDefault();
    });
    $("body").on("change", "._filtered-results-header ._filter-sort", function(e) {
      var sel;
      sel = $(this);
      query(sel).sort_by = sel.val();
      decko.filter.refilter(this);
      return e.preventDefault;
    });
    $("body").on("show.bs.offcanvas", "._offcanvas-filter", function() {
      var ocbody, path;
      ocbody = $(this).find(".offcanvas-body");
      if (ocbody.html() !== "") {
        return;
      }
      path = decko.path(ocbody.data("path") + "/filter_bars?" + $.param(query(ocbody)));
      return $.get(path, function(data) {
        ocbody.html(data);
        return ocbody.slot().trigger("decko.slot.ready");
      });
    });
    return $("body").on("click", "._filtered-body-toggle", function(e) {
      var link;
      link = $(this);
      link.parent().children().removeClass("btn-light");
      link.addClass("btn-light");
      query(link).filtered_body = link.data("view");
      decko.filter.refilter(this);
      return e.preventDefault();
    });
  });

  query = function(el) {
    var form;
    form = findInFilteredContent(el, "form.filtered-results-form");
    return form.data("query");
  };

  resetOffCanvas = function(el) {
    var ocbody;
    ocbody = findInFilteredContent(el, ".offcanvas-body");
    ocbody.parent().offcanvas("hide");
    return ocbody.empty();
  };

  updateUrlBarWithFilter = function(el, query) {
    var query_string, tab;
    if (!el.closest('._noFilterUrlUpdates')[0]) {
      query_string = '?' + $.param(query);
      if ((tab = el.closest(".tabbable").find(".nav-link.active").data("tabName"))) {
        query_string += "&tab=" + tab;
      }
      return window.history.pushState("filter", "filter", query_string);
    }
  };

  findInFilteredContent = function(el, selector) {
    return $(el).closest("._filtered-content").find(selector);
  };

  removeFromQuery = function(link) {
    var filter, i, key, remove, value;
    filter = query(link).filter;
    remove = link.data("removeFilter");
    key = remove[0];
    value = remove[1];
    if (Array.isArray(filter[key])) {
      i = filter[key].indexOf(value);
      return filter[key].splice(i, 1);
    } else {
      return delete filter[key];
    }
  };

}).call(this);

// filtered_list.js.coffee
(function() {
  var FilterItemsBox, filterBox;

  $.extend(decko, {
    itemAdded: function(func) {
      return $('document').ready(function() {
        return $('body').on('itemAdded', '._filtered-list-item', function(e) {
          return func.call(this, $(this));
        });
      });
    },
    itemsAdded: function(func) {
      return $('document').ready(function() {
        return $('body').on('itemsAdded', '.card-slot', function(e) {
          return func.call(this, $(this));
        });
      });
    }
  });

  $(window).ready(function() {
    $("body").on("click", "._filter-items ._add-selected", function(event) {
      $(this).closest('.modal').modal("hide");
      return filterBox(this).addSelected();
    });
    $("body").on("click", "._select-all", function() {
      filterBox(this).selectAll();
      return $(this).prop("checked", false);
    });
    $("body").on("click", "._deselect-all", function() {
      filterBox(this).deselectAll();
      return $(this).prop("checked", true);
    });
    $("body").on("click", "._filter-items ._unselected input._checkbox-list-checkbox", function() {
      return filterBox(this).selectAndUpdate(this);
    });
    $("body").on("click", "._filter-items ._selected input._checkbox-list-checkbox", function() {
      return filterBox(this).deselectAndUpdate(this);
    });
    return $('body').on('click', '._filtered-list-item-delete', function() {
      return $(this).closest('._filtered-list-item').remove();
    });
  });

  filterBox = function(el) {
    return new FilterItemsBox(el);
  };

  FilterItemsBox = (function() {
    function FilterItemsBox(el) {
      this.box = $(el).closest("._filter-items");
      this.bin = this.box.find("._selected-bin");
      this.selected_items = this.box.find("._selected-item-list");
      this.help_text = this.box.find("._filter-help");
      this.addSelectedButton = this.box.find("._add-selected");
      this.deselectAllLink = this.box.find("._deselect-all");
      this.config = this.box.data();
    }

    FilterItemsBox.prototype.selectAll = function() {
      var t;
      t = this;
      this.box.find("._unselected input._checkbox-list-checkbox").each(function() {
        return t.select(this);
      });
      return this.updateOnSelect();
    };

    FilterItemsBox.prototype.deselectAll = function() {
      var t;
      t = this;
      this.box.find("._selected input._checkbox-list-checkbox").each(function() {
        return t.deselect(this);
      });
      return this.updateOnSelect();
    };

    FilterItemsBox.prototype.select = function(checkbox) {
      var item;
      checkbox = $(checkbox);
      item = checkbox.slot();
      if (this.duplicatesOk()) {
        item.after(item.clone());
      }
      checkbox.prop("checked", true);
      return this.bin.append(item);
    };

    FilterItemsBox.prototype.deselect = function(checkbox) {
      return $(checkbox).slot().remove();
    };

    FilterItemsBox.prototype.selectAndUpdate = function(checkbox) {
      this.select(checkbox);
      return this.updateOnSelect();
    };

    FilterItemsBox.prototype.deselectAndUpdate = function(checkbox) {
      this.deselect(checkbox);
      return this.updateOnSelect();
    };

    FilterItemsBox.prototype.updateOnSelect = function() {
      var f;
      if (!this.duplicatesOk()) {
        this.trackSelectedIds();
        f = new decko.compactFilter(this.box.find('._compact-filter'));
        f.update();
        this.updateUnselectedCount();
      }
      return this.updateSelectedCount();
    };

    FilterItemsBox.prototype.sourceSlot = function() {
      return this.box.slot();
    };

    FilterItemsBox.prototype.addSelected = function() {
      var cardId, i, len, ref, submit;
      submit = this.sourceSlot().find(".submit-button");
      submit.attr("disabled", true);
      ref = this.selectedIds();
      for (i = 0, len = ref.length; i < len; i++) {
        cardId = ref[i];
        this.addSelectedCard(cardId);
      }
      submit.attr("disabled", false);
      return this.sourceSlot().trigger("itemsAdded");
    };

    FilterItemsBox.prototype.addSelectedCard = function(cardId) {
      var fib, slot;
      slot = this.sourceSlot();
      fib = this;
      return $.ajax({
        url: this.addSelectedUrl(cardId),
        async: false,
        success: function(html) {
          return fib.addItem(slot, $(html));
        },
        error: function(_jqXHR, textStatus) {
          return slot.notify("error: " + textStatus, "error");
        }
      });
    };

    FilterItemsBox.prototype.addItem = function(slot, item) {
      slot.find("._filtered-list").append(item);
      item.trigger("itemAdded");
      return true;
    };

    FilterItemsBox.prototype.addSelectedUrl = function(cardId) {
      return decko.path("~" + cardId + "/" + this.config.itemView + "?slot[wrap]=" + this.config.itemWrap);
    };

    FilterItemsBox.prototype.duplicatesOk = function() {
      return this.config.itemDuplicable;
    };

    FilterItemsBox.prototype.trackSelectedIds = function() {
      var ids;
      ids = this.prefilteredIds().concat(this.selectedIds());
      return this.box.find("._not-ids").val(ids.toString());
    };

    FilterItemsBox.prototype.prefilteredIds = function() {
      return this.prefilteredData("cardId");
    };

    FilterItemsBox.prototype.prefilteredData = function(field) {
      var items;
      items = this.sourceSlot().find(this.box.data("itemSelector"));
      return this.arrayFromField(items, field);
    };

    FilterItemsBox.prototype.selectedIds = function() {
      return this.selectedData("cardId");
    };

    FilterItemsBox.prototype.selectedNames = function() {
      return this.selectedData("cardName");
    };

    FilterItemsBox.prototype.selectedData = function(field) {
      return this.arrayFromField(this.bin.children(), field);
    };

    FilterItemsBox.prototype.arrayFromField = function(rows, field) {
      return rows.map(function() {
        return $(this).data(field);
      }).toArray();
    };

    FilterItemsBox.prototype.updateUnselectedCount = function() {
      var count;
      count = this.box.find("._search-checkbox-list").children().length;
      this.box.find("._unselected-items").html(count);
      return this.box.find("._select-all").attr("disabled", count > 0);
    };

    FilterItemsBox.prototype.updateSelectedCount = function() {
      var count;
      count = this.bin.children().length;
      this.box.find("._selected-items").html(count);
      this.deselectAllLink.attr("disabled", count === 0);
      this.addSelectedButton.attr("disabled", count === 0);
      return this.updateSelectedSectionVisibility(count > 0);
    };

    FilterItemsBox.prototype.updateSelectedSectionVisibility = function(items_present) {
      if (items_present) {
        this.selected_items.show();
        return this.help_text.hide();
      } else {
        this.selected_items.hide();
        return this.help_text.show();
      }
    };

    return FilterItemsBox;

  })();

}).call(this);

// selectable_filtered_content.js.coffee
(function() {
  $(window).ready(function() {
    $('body').on("ajax:beforeSend", "._selectable-filter-link", function(_event, _xhr, opt) {
      return opt.noSlotParams = true;
    });
    $("body").on("ajax:success", "._selectable-filter-link", function() {
      return $("._selectable-filtered-content").data("source-link", $(this));
    });
    return $("body").on("click", "._selectable-filtered-content .search-result-item", function(e) {
      var item, source_link;
      item = $(this);
      source_link = item.closest("._selectable-filtered-content").data("source-link");
      source_link.trigger("decko.filter.selection", item);
      item.closest(".modal").modal("hide");
      e.preventDefault();
      return e.stopPropagation();
    });
  });

}).call(this);
