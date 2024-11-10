import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.ksvg as KSvg

// import QtQuick.Controls.Styles 1.1 as QtQuickControlStyle
// import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

RowLayout {
	id: searchFiltersViewItem
	Layout.fillWidth: true
	spacing: 0

	property string runnerId: ''
	property int indentLevel: 0

	property alias iconSource: applyFilterButton.icon.source
	property alias text: applyFilterButton.text
	property alias subText: applyFilterButton.subText

	property alias checkBox: isDefaultFilter
	property alias applyButton: applyFilterButton

	signal applyButtonClicked()

	property var surfaceNormal: KSvg.FrameSvgItem {
		anchors.fill: parent
		imagePath: "widgets/button"
		prefix: "normal"
		// prefix: style.flat ? ["toolbutton-hover", "normal"] : "normal"
	}

	Item { // Align CheckBoxes buttons to "All"
		Layout.minimumWidth: surfaceNormal.margins.left + (config.flatButtonIconSize + surfaceNormal.margins.left) * searchFiltersViewItem.indentLevel
		Layout.maximumWidth: Layout.minimumWidth
		Layout.fillHeight: true
	}

	PlasmaComponents3.ToolButton {
		id: applyFilterButton
		Layout.fillWidth: true
		property string subText: ""

		// style: PlasmaStyles.ToolButtonStyle {
		// 	id: style
		// 	readonly property bool smallIcon: !control.subText

		// 	label: RowLayout {
		// 		Kirigami.Icon {
		// 			source: control.iconSource
		// 			Layout.preferredHeight: style.smallIcon ? config.flatButtonIconSize : -1
		// 			Layout.preferredWidth: style.smallIcon ? config.flatButtonIconSize : -1
		// 		}
		// 		ColumnLayout {
		// 			id: textColumn
		// 			Layout.fillWidth: true
		// 			Layout.fillHeight: true
		// 			spacing: 0
		// 			PlasmaComponents3.Label {
		// 				Layout.fillWidth: true
		// 				text: control.text
		// 				horizontalAlignment: Text.AlignLeft
		// 				maximumLineCount: 1
		// 				elide: Text.ElideRight
		// 			}
		// 			PlasmaComponents3.Label {
		// 				Layout.fillWidth: true
		// 				text: control.subText
		// 				horizontalAlignment: Text.AlignLeft
		// 				visible: control.subText
		// 				color: config.menuItemTextColor2
		// 				maximumLineCount: 1
		// 				elide: Text.ElideRight
		// 			}
		// 		}
		// 	}
		// }
		onClicked: {
			if (searchFiltersViewItem.runnerId) {
				search.filters = [searchFiltersViewItem.runnerId]
			}
			searchFiltersViewItem.applyButtonClicked()
			searchResultsView.filterViewOpen = false
		}
	}

	PlasmaComponents3.CheckBox {
		id: isDefaultFilter
		checked: search.defaultFiltersContains(searchFiltersViewItem.runnerId)
		onCheckedChanged: {
			if (checked) {
				search.addDefaultFilter(searchFiltersViewItem.runnerId)
			} else {
				search.removeDefaultFilter(searchFiltersViewItem.runnerId)
			}
		}
		Layout.fillHeight: true
		text: i18n("Default")
	}

	Item { // Align CheckBoxes buttons to "All"
		Layout.minimumWidth: surfaceNormal.margins.right
		Layout.maximumWidth: Layout.minimumWidth
		Layout.fillHeight: true
		// visible: isDefaultFilter.visible && searchFiltersViewItem.indentLevel > 0
	}
}
