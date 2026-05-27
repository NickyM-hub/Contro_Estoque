import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionPostgreSQL {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/controle_estoque";
        String usuario = "postgres";
        String senha = "Kir@469";

        try {
            // Tentando estabelecer a conexão
            Connection conexao = DriverManager.getConnection(url, usuario, senha);
            System.out.println("Conexão estabelecida com sucesso!");

            // Fechar a conexão
            conexao.close();

        } catch (SQLException e) {
            System.out.println("Erro ao conectar ao banco de dados.");
            e.printStackTrace();
        }
    }
}