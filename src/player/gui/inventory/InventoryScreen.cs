using Godot;
using Godot.Collections;
using System;
using System.Linq;

public partial class InventoryScreen : PanelContainer {
	[Signal]
	public delegate void ItemSelectedEventHandler(Item item);

	[Export]
	private InventoryDisplayPanel infoPanel;
	[Export]
	private VBoxContainer itemsScroller;
	[Export]
	private VBoxContainer equipmentScroller;
	[Export]
	private VBoxContainer spellsScroller;
	[Export]
	private VBoxContainer keyItemsScroller;
	[Export]
	private TabContainer tabContainer;
	[Export]
	private CheckBox idCheckBox;
	[Export]
	private CheckBox nameCheckBox;

	public void Setup(Inventory inventory) {
		var populateTab = (Array<Item> items, VBoxContainer scroller) => {
			foreach(Item item in items) {
				Button button = new();
				button.Name = item.Name;
				button.SetMeta("id", item.Id);
				button.Text = $"{item.Name} ({item.Quantity})";
				var temp = item;
				button.Connect(Button.SignalName.Pressed, 
						Callable.From(() => EmitSignal(SignalName.ItemSelected, temp)));
				scroller.AddChild(button);

				if(item.Quantity == 0) {
					button.Hide();
				}
			}
		};
		populateTab(inventory.Items, itemsScroller);
		populateTab(inventory.Equipment, equipmentScroller);
		populateTab(inventory.SpellScrolls, spellsScroller);
		populateTab(inventory.KeyItems, keyItemsScroller);

		inventory.Connect(Inventory.SignalName.QuantityChanged, 
				new Callable(this, MethodName.OnQuantityChanged));
	}

	public void SortById(int tab=-1) {
		// This method is called when the user exits from this screen,
		// to help prevent potential bugs 
		// (id will likely be used as an index, so they need to be in ord).
		// When this happens, the checkboxes will not reset.
		idCheckBox.SetPressedNoSignal(true);
		nameCheckBox.SetPressedNoSignal(false);

		var buttons = Enumerable.OrderBy<Node, int>(
				itemsScroller.GetChildren(), (Node item) => (int)item.GetMeta("id"));

		Node scroller;
		if(tab == -1) tab = tabContainer.CurrentTab;
		switch(tab) {
			case 2: 
				scroller = spellsScroller;
				break;
			case 1:
				scroller = equipmentScroller;
				break;
			case 3:
				scroller = keyItemsScroller;
				break;
			default:
				scroller = itemsScroller;
				break;
		}

		for(int i = 0; i < buttons.Count(); i++) {
			scroller.MoveChild(buttons.ElementAt(i), i);
		}
	}
	public void SortByAlphabetical() {
		var buttons = Enumerable.OrderBy<Node, string>(
				itemsScroller.GetChildren(), (Node item) => item.Name);

		Node scroller;
		switch(tabContainer.CurrentTab) {
			case 2: 
				scroller = spellsScroller;
				break;
			case 1:
				scroller = equipmentScroller;
				break;
			case 3:
				scroller = keyItemsScroller;
				break;
			default:
				scroller = itemsScroller;
				break;
		}

		for(int i = 0; i < buttons.Count(); i++) {
			scroller.MoveChild(buttons.ElementAt(i), i);
		}
	}

	private void OnQuantityChanged(Item item, int amount) {
		VBoxContainer scroller;
		int tab;
		if(item is KeyItem) {
			scroller = keyItemsScroller;
			tab = 3;
		}
		else if(item is SpellScroll) {
			scroller = spellsScroller;
			tab = 2;
		}
		else if(item is Equipment) {
			scroller = equipmentScroller;
			tab = 1;
		}
		else {
			scroller = itemsScroller;
			tab = 0;
		}

		SortById(tab);

		Button button = scroller.GetChild<Button>(item.Id);
		button.Text = $"{item.Name} ({amount})";

		if(amount == 0) button.Hide();
	}
	private void OnTabChanged(int index) {
		SortById();
	}
}
