<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.*, java.io.*, com.google.gson.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DB 저장 결과</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    // searchForm에서 POST로 보낸 데이터를 받음
    String jsonData = request.getParameter("_jsonData");
    
    if (jsonData == null || jsonData.trim().length() == 0) {
        out.println("<script>alert('데이터가 없습니다.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    int savedCount = 0;

    try {
        // 1. 데이터 디코딩 (searchForm에서 URLEncoder로 보냈으므로 여기서 Decode)
        String decodedJson = URLDecoder.decode(jsonData, "UTF-8");
        
        JsonParser parser = new JsonParser();
        JsonObject jsonObj = parser.parse(decodedJson).getAsJsonObject();
        JsonArray items = jsonObj.getAsJsonArray("items");

        // 2. DB 연결 (본인 환경에 맞게 수정 필요)
        String driver = "com.mysql.cj.jdbc.Driver"; 
        String dbUrl = "jdbc:mysql://localhost/test_c?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8";
        String dbId = ""; //  DB 아이디
        String dbPw = ""; // DB 비밀번호
        
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbId, dbPw);

        // 3. 쿼리 준비
        String sql = "INSERT INTO saves (link, title, description) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);

        // 4. 데이터 바인딩 및 배치 추가
        for (int i = 0; i < items.size(); i++) {
            JsonObject item = items.get(i).getAsJsonObject();

            String title = item.get("title").getAsString();
            String link = item.get("link").getAsString();
            String description = item.get("description").getAsString();

      
            pstmt.setString(1, link);
            pstmt.setString(2, title);
            pstmt.setString(3, description);

            pstmt.addBatch(); // 메모리에 적재
        }

        // 5. 일괄 실행
        int[] result = pstmt.executeBatch();
        savedCount = result.length;
        
    	} catch(Exception e) {
        	e.printStackTrace();
	    } finally {
	        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
	        if (conn != null) try { conn.close(); } catch(Exception e) {}
	    }
%>
    <h2>데이터베이스 저장 완료</h2>
    <p><%=savedCount%>개의 항목이 데이터베이스에 저장되었습니다.</p>
	<a href="searchForm.jsp">다시 검색</a>
</body>
</html>