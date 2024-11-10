import QtQuick
import org.kde.plasma.extras as PlasmaExtras

ListView {
	id: listView
	clip: true
	cacheBuffer: 200 // Don't unload when scrolling (prevent stutter)

	// snapMode: ListView.SnapToItem
	keyNavigationWraps: true
	highlightMoveDuration: 0
	highlightResizeDuration: 0

	property bool showItemUrl: true
	property bool showDesktopFileUrl: false
	property int iconSize: 36 * Screen.devicePixelRatio

	section.delegate: KickerSectionHeader {}

	delegate: MenuListItem {}

	property var modelList: model ? model.list : []
	
	// currentIndex: 0
	// Connections {
	// 	target: appsModel.allAppsModel
	// 	function onRefreshing() {
	// 		console.log('appsList.onRefreshing')
	// 		appsList.model = []
	// 		// console.log('search.results.onRefreshed')
	// 		appsList.currentIndex = 0
	// 	}
	// 	function onRefreshed() {
	// 		console.log('appsList.onRefreshed')
	// 		// appsList.model = appsModel.allAppsList
	// 		appsList.model = appsModel.allAppsList
	// 		appsList.modelList = appsModel.allAppsList.list
	// 		appsList.currentIndex = 0
	// 	}
	// }

	highlight: PlasmaExtras.Highlight {
		visible: listView.currentItem && !listView.currentItem.isSeparator
	}

	// function triggerIndex(index) {
	// 	model.triggerIndex(index)
	// }

	function goUp() {
		if (verticalLayoutDirection == ListView.TopToBottom) {
			decrementCurrentIndex()
		} else { // ListView.BottomToTop
			incrementCurrentIndex()
		}
	}

	function goDown() {
		if (verticalLayoutDirection == ListView.TopToBottom) {
			incrementCurrentIndex()
		} else { // ListView.BottomToTop
			decrementCurrentIndex()
		}
	}

	function skipToMin() {
		currentIndex = Math.max(0, currentIndex - 10)
	}

	function skipToMax() {
		currentIndex = Math.min(currentIndex + 10, count-1)
	}

	function pageUp() {
		if (verticalLayoutDirection == ListView.TopToBottom) {
			skipToMin()
		} else { // ListView.BottomToTop
			skipToMax()
		}
	}

	function pageDown() {
		if (verticalLayoutDirection == ListView.TopToBottom) {
			skipToMax()
		} else { // ListView.BottomToTop
			skipToMin()
		}
	}
}
