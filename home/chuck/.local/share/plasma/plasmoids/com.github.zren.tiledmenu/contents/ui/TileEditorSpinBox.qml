import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3

PlasmaComponents3.SpinBox {
	id: spinBox
	property string key: ''
	Layout.fillWidth: true
	implicitWidth: 20
	value: appObj.tile && appObj.tile[key] || 0
	property bool updateOnChange: false
	onValueChanged: {
		if (key && updateOnChange) {
			appObj.tile[key] = value
			appObj.tileChanged()
			tileGrid.tileModelChanged()
		}
	}

	Connections {
		target: appObj

		function onTileChanged() {
			if (key && tile) {
				spinBox.updateOnChange = false
				spinBox.value = appObj.tile[key] || 0
				spinBox.updateOnChange = true
			}
		}
	}
}
