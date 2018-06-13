import java.lang.Exception;

public class TestJavaFx {
	public static void main(String[] args) {
		try {
			String rootTagTest = javafx.fxml.FXMLLoader.ROOT_TAG;
			System.out.println("INSTALLED");
		}
		catch(Exception e) {
			System.out.println("MISSING");
		}
		System.exit(0);
	}
}
