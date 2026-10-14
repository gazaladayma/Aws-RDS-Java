<%@ page import="java.sql.*" %>
<%
    String userName = request.getParameter("userName");
    String password = request.getParameter("password");

    String dbHost = System.getenv("DB_HOST");
    String dbName = System.getenv("DB_NAME");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    if (dbHost == null || dbName == null ||
        dbUser == null || dbPassword == null ||
        dbHost.isBlank() || dbName.isBlank() ||
        dbUser.isBlank() || dbPassword.isBlank()) {
        response.sendError(500, "Database configuration is missing.");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        String sql = "SELECT * FROM USER WHERE userName = ? AND password = ?";

        try (
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://" + dbHost + ":3306/" + dbName,
                dbUser,
                dbPassword
            );
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, userName);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    session.setAttribute("userName", userName);
                    response.sendRedirect("success.jsp");
                } else {
                    out.println("Invalid username or password. <a href='index.jsp'>Try again</a>");
                }
            }
        }
    } catch (Exception e) {
        application.log("Login failed due to a database or application error.", e);
        response.sendError(500, "Unable to process login right now.");
    }
%>
