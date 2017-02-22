package sample;

import java.io.File;

import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.GridPane;
import javafx.stage.DirectoryChooser;
import javafx.stage.Stage;

public class Controller {
    @FXML
    public GridPane appPane;

    @FXML
    public ListView<String> selectedList;

    @FXML
    public ListView<String> unselectedList;

    @FXML
    public ImageView selectImage;

    @FXML
    public ImageView unselectImage;

    @FXML
    public Label selectedCount;

    @FXML
    public Label unselectedCount;

    @FXML
    public Label dataPathLabel;

    private Stage appStage;

    private String dataPath;

    private int unselectedTotal;

    private int unselectedCurrent;

    private int selectedTotal;

    private int selectedCurrent;

    @FXML
    public void initialize() {
        selectedList.getSelectionModel().selectedItemProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                selectImage.setImage(new Image("file:" + dataPath + "/" + newValue));
                selectedCurrent = selectedList.getSelectionModel().getSelectedIndex() + 1;
                refreshCounters();
            }
        });
        unselectedList.getSelectionModel().selectedItemProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                unselectImage.setImage(new Image("file:" + dataPath + "/" + newValue));
                unselectedCurrent = unselectedList.getSelectionModel().getSelectedIndex() + 1;
                refreshCounters();
            }
        });
    }

    @FXML
    public void importButtonClick() {
        DirectoryChooser directoryChooser = new DirectoryChooser();
        directoryChooser.setTitle("Import Images");
        File file = directoryChooser.showDialog(this.appStage);
        if (file != null && file.isDirectory()) {
            this.dataPath = file.getPath();
            unselectedList.getItems().clear();
            selectedList.getItems().clear();
            File[] weeks = new File(this.dataPath).listFiles();
            if (weeks != null) {
                int chnCount = 0;
                for (File week : weeks) {
                    if (week != null && week.isDirectory()) {
                        String weekName = week.getName();
                        File[] chn = week.listFiles();
                        if (chn != null) {
                            chnCount += chn.length;
                            for (File i : chn) {
                                this.unselectedList.getItems().add(weekName + "/" + i.getName());
                            }
                        }
                    }
                }
                selectedTotal = 0;
                selectedCurrent = 0;
                unselectedTotal = chnCount;
                unselectedCurrent = (chnCount == 0) ? 0 : 1;
                refreshCounters();
                dataPathLabel.setText(this.dataPath);
            }
        }
    }

    @FXML
    public void onSelectKeyTyped(KeyEvent e) {
        String c = e.getCharacter();
        if (c.equals(" ")) {
            // select stuff
            String selectedChannel = unselectedList.getSelectionModel().getSelectedItem();
            unselectedList.getItems().remove(selectedChannel);
            selectedList.getItems().add(selectedChannel);
        }
        selectedTotal++;
        unselectedCurrent--;
        unselectedTotal--;
        refreshCounters();
    }

    @FXML
    public void onUnselectKeyTyped(KeyEvent e) {
        String c = e.getCharacter();
        if (c.equals(" ")) {
            // select stuff
            String selectedChannel = selectedList.getSelectionModel().getSelectedItem();
            selectedList.getItems().remove(selectedChannel);
            unselectedList.getItems().add(selectedChannel);
        }
        selectedCurrent--;
        selectedTotal--;
        unselectedTotal++;
        refreshCounters();
    }

    @FXML
    public void exportButtonClick(KeyEvent e) {
        for (String s : unselectedList.getItems()) {
            new File(dataPath + "/" + s).delete();
        }
        unselectedList.getItems().clear();
        unselectedCurrent = 0;
        unselectedTotal = 0;
        refreshCounters();
        try {
            LineExporter.export(this.dataPath);
            showDialog("Export Success", "HTML saved to " + this.dataPath);
        } catch (Exception x) {
            showDialog("Export Failure", x.getMessage());
        }
    }

    private void refreshCounters() {
        selectedCount.setText(selectedCurrent + "/" + selectedTotal);
        unselectedCount.setText(unselectedCurrent + "/" + unselectedTotal);
    }

    void setAppStage(Stage stage) {
        this.appStage = stage;
    }

    private void showDialog( String header, String content) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("SimpleViewer");
        alert.setHeaderText(header);
        alert.setContentText(content);
        alert.showAndWait();
    }
}
