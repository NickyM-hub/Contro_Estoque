import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexao {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/controle_estoque";
        String user = "estoque";
        String pass = "cont-est01";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Conectado com sucesso!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}