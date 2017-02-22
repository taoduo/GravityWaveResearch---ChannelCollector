package sample;

import java.io.File;

import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.fxml.FXML;
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

    public Stage appStage;

    public String dataPath;

    public int unselectedTotal;

    public int unselectedCurrent;

    public int selectedTotal;

    public int selectedCurrent;

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
        if (file != null) {
            this.dataPath = file.getPath();
            File[] images = new File(this.dataPath).listFiles();
            unselectedList.getItems().clear();
            selectedList.getItems().clear();
            if (images != null) {
                for (File i : images) {
                    this.unselectedList.getItems().add(i.getName());
                }
                selectedCurrent = 0;
                selectedTotal = 0;
                unselectedCurrent = 1;
                unselectedTotal = images.length;
                refreshCounters();
                dataPathLabel.setText(this.dataPath);
            }
        }

    }

    @FXML
    public void exportButtonClick() {
        for (String s : unselectedList.getItems()) {
            new File(dataPath + "/" + s).delete();
        }
        unselectedList.getItems().clear();
        unselectedCurrent = 0;
        unselectedTotal = 0;
        refreshCounters();
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

    public void refreshCounters() {
        selectedCount.setText(selectedCurrent + "/" + selectedTotal);
        unselectedCount.setText(unselectedCurrent + "/" + unselectedTotal);
    }

    public void setAppStage(Stage stage) {
        this.appStage = stage;
    }
}
