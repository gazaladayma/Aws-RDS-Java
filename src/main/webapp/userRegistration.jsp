<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String userName = request.getParameter("userName");
    String password = request.getParameter("password");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");

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

        String sql = "INSERT INTO USER " +
            "(first_name, last_name, email, username, password, regdate) " +
            "VALUES (?, ?, ?, ?, ?, CURDATE())";

        try (
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://" + dbHost + ":3306/" + dbName,
                dbUser,
                dbPassword
            );
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, userName);
            ps.setString(5, password);

            int rowsInserted = ps.executeUpdate();

            if (rowsInserted > 0) {
                response.sendRedirect("welcome.jsp");
            } else {
                response.sendRedirect("index.jsp");
            }
        }
    } catch (Exception e) {
        application.log("Registration failed due to a database or application error.", e);
        response.sendError(500, "Unable to complete registration right now.");
    }
%>
