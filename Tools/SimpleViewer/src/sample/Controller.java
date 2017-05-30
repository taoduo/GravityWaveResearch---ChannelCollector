package sample;

import java.io.File;

import javafx.application.Application;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TextField;
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

    @FXML
    public TextField commentText;

    @FXML
    public TextField sourceText;

    @FXML
    public Application app;

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
                                if (!i.getName().startsWith(".") && i.getName().endsWith(".jpg")) {
                                    this.unselectedList.getItems().add(weekName + "/" + i.getName());
                                }
                            }
                        }
                    }
                }
                selectedTotal = 0;
                selectedCurrent = 0;
                unselectedTotal = chnCount;
                unselectedCurrent = 0;
                refreshCounters();
                dataPathLabel.setText(this.dataPath);
            } else {
                showDialog("Import Failure", "NULL FOLDER");
            }
        }
    }

    @FXML
    public void selectAllButtonClick() {
        while (!unselectedList.getItems().isEmpty()) {
            // select stuff
            String selectedChannel = unselectedList.getItems().get(0);
            select(selectedChannel);
        }
    }

    @FXML
    public void exportButtonClick() {
        for (String s : unselectedList.getItems()) {
            if (!new File(dataPath + "/" + s).delete()) {
                showDialog("Delete Failed", "Deleting " + dataPath + "/" + s + " failed");
            }
        }
        unselectedList.getItems().clear();
        unselectedCurrent = 0;
        unselectedTotal = 0;
        refreshCounters();
        try {
            LineExporter.export(this.dataPath, commentText.getText(), sourceText.getText());
            showDialog("Export Success", "HTML saved to " + this.dataPath);
        } catch (Exception x) {
            x.printStackTrace();
            showDialog("Export Failure", x.getMessage());
        }
    }

    @FXML
    public void onSelectKeyTyped(KeyEvent e) {
        if (e.getCharacter().equals(" ")) {
            // select stuff
            String selectedChannel = unselectedList.getSelectionModel().getSelectedItem();
            select(selectedChannel);
        }
    }

    @FXML
    public void onUnselectKeyTyped(KeyEvent e) {
        if (e.getCharacter().equals(" ")) {
            // select stuff
            String selectedChannel = selectedList.getSelectionModel().getSelectedItem();
            selectedList.getItems().remove(selectedChannel);
            if (selectedCurrent != 1) {
                selectedList.getSelectionModel().select(selectedCurrent);
            }
            unselectedList.getItems().add(selectedChannel);
            selectedTotal--;
            unselectedTotal++;
            refreshCounters();
        }
    }

    @FXML
    public void previewBtnClick() {
        this.app.getHostServices().showDocument("file://" + dataPath + "/index.html");
    }

    @FXML
    public void commentBtnClick() {
        try {
            LineExporter.export(this.dataPath, commentText.getText(), sourceText.getText());
            commentText.clear();
            showDialog("Success", "HTML saved to " + this.dataPath);
        } catch (Exception x) {
            x.printStackTrace();
            showDialog("Failure", x.getMessage());
        }
    }

    private void refreshCounters() {
        selectedCount.setText(selectedCurrent + "/" + selectedTotal);
        unselectedCount.setText(unselectedCurrent + "/" + unselectedTotal);
    }

    private void select(String channel) {
        unselectedList.getItems().remove(channel);
        if (unselectedCurrent != 1) {
            unselectedList.getSelectionModel().select(unselectedCurrent);
        }
        selectedList.getItems().add(channel);
        selectedTotal++;
        unselectedTotal--;
        refreshCounters();
    }

    void setAppStage(Stage stage) {
        this.appStage = stage;
    }
    void setApp(Application app) { this.app = app; }
    private void showDialog(String header, String content) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("SimpleViewer");
        alert.setHeaderText(header);
        alert.setContentText(content);
        alert.showAndWait();
    }
}
