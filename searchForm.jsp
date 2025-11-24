<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.net.*, com.google.gson.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>네이버 지식iN 검색 과제</title>
<link rel="stylesheet" href="style.css">
</head>
<body>

<%
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("_keyword"); // 검색어
    String pageNum = request.getParameter("_pageNum"); // 페이지 번호
    String sort = request.getParameter("_sort"); // 정렬 기준(sim, date, point)

    if(sort == null || sort.equals("")) sort = "sim";  // 기본값 설정

    int currentPage = 1; 
    
    if(pageNum != null && !pageNum.equals("")) {
        try { 
        	currentPage = Integer.parseInt(pageNum); 
        	} catch(Exception e) { 
        		currentPage = 1; 
        	}
    }
%>

    <h1>네이버 지식iN 검색</h1>

    <div class="search-box">
        <form action="searchForm.jsp" method="get">
            <div>
                <input type="text" name="_keyword" class="input-text" 
                       placeholder="검색어를 입력하세요"
                       value="<%=(keyword != null) ? keyword : "" %>">
                <input type="submit" value="검색" class="btn-search">
            </div>
            <div class="sort-radio-area">
                <input type="radio" name="_sort" value="sim" id="r1" <% if(sort.equals("sim")) out.print("checked"); %>> <label for="r1">정확도순</label>
                <input type="radio" name="_sort" value="date" id="r2" <% if(sort.equals("date")) out.print("checked"); %>> <label for="r2">날짜순</label>
                <input type="radio" name="_sort" value="point" id="r3" <% if(sort.equals("point")) out.print("checked"); %>> <label for="r3">추천순👍</label>
            </div>
        </form>
    </div>

<%           		
    if (keyword != null && !keyword.trim().equals("")) {
    	// 1. 네이버 검색 API 요청을 위한 준비 작업
		// 네이버 개발자 센터에서 발급받은 ID와 Secreat 키
        String myId = ""; // 본인 ID
        String mySecret = ""; // 본인 비번
        // 검색어 인코딩 (한글 깨짐 방지)
        String apiURL = "https://openapi.naver.com/v1/search/kin.json?display=100&sort="
        				+ sort + "&query=" + URLEncoder.encode(keyword, "UTF-8");
	   
        // 2. 연결 작업
        URL url = new URL(apiURL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        // 서버에 검색 결과를 받기 위해 GET 방식 요청
        conn.setRequestMethod("GET");
        conn.setRequestProperty("X-Naver-Client-Id", myId);
        conn.setRequestProperty("X-Naver-Client-Secret", mySecret);
        
        // 3. 결과 읽어오는 작업
        BufferedReader br = new BufferedReader(
        		new InputStreamReader(conn.getInputStream(), "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while((line = br.readLine()) != null) {
        	sb.append(line);
        }
        br.close();
        
        // 4. JSON 데이터 파싱 (com.google.gson.*)
        String jsonData = sb.toString();
        // JSON 파싱 객체 생성
        JsonParser parser = new JsonParser();
        JsonObject obj = parser.parse(jsonData).getAsJsonObject();
        JsonArray items = obj.getAsJsonArray("items");
     	// 자바 리스트 생성하여 옮겨 담기
        List<JsonObject> list = new ArrayList<>();
        for(JsonElement j : items) {
        	list.add(j.getAsJsonObject());
        }
     	
     	// 5. 페이징 처리 및 출력
        int totalCount = list.size(); // 전체 데이터 수
        int pageSize = 10; // 한 페이지당 보여줄 개수
        int totalPage = (int) Math.ceil((double)totalCount / pageSize); // 전체 페이지 수 계산
        int startIdx = (currentPage - 1) * pageSize; // 현재 페이지의 시작 인덱스
        int endIdx = Math.min(startIdx + pageSize, totalCount); // 현재 페이지의 끝 인덱스
%>
        <div class="save-area">
            <form action="saveToDB.jsp" method="post">
                <input type="hidden" name="_jsonData" value="<%= URLEncoder.encode(jsonData, "UTF-8") %>">
                <input type="submit" value="검색결과 DB 저장" class="btn-db">
            </form>
        </div>

        <table class="result-table">
            <thead>
                <tr>
                    <th width="50">번호</th>
                    <th width="20%">제목</th>
                    <th width="15%">URL</th> 
                    <th>내용요약</th>
                </tr>
            </thead>
            <tbody>
            <% 
           		// 6. 현재 페이지에 해당하는 데이터 출력
                for(int i = startIdx; i < endIdx; i++) {
                    JsonObject item = list.get(i);
                    String title = item.get("title").getAsString();
                    String link = item.get("link").getAsString();
                    String desc = item.get("description").getAsString();
                    
                    // 본문 내용 길이 조절
                    String shortDesc = desc;
                    if(shortDesc.length() > 80) {
                    	shortDesc = shortDesc.substring(0, 80) + "...";
                    }
                    
                    // 제목 길이 조절
                    String shortTitle = title;
                    if(shortTitle.length() > 40) {
                    	shortTitle = shortTitle.substring(0, 40) + "...";
                    }
                    
                    // URL 길이 조절
                    String shortLink = link;
                    if(shortLink.length() > 30) {
                        shortLink = shortLink.substring(0, 30) + "...";
                    }
            %>
                <tr>
                    <td style="text-align:center;"><%= i + 1 %></td>
                    
                    <td style="font-weight:bold;">
                        <%= shortTitle %>
                    </td>
                    
                    <td>
                        <a href="<%= link %>" target="_blank" class="link-url">
                            <%= shortLink %>
                        </a>
                    </td>
                    
                    <td><%=shortDesc %></td>
                </tr>
            <% 
                } 
            %>
            </tbody>
        </table>
        
        <div class="paging-area">
            <% 
                for(int i = 1; i <= totalPage; i++) {
                	// 현재 페이지는 링크 없이 강조 표시
                    if(i == currentPage) {
            %>
                        <span class="page-num current"><%= i %></span>
            <% 
            		// 다른 페이지는 이동 링크 생성 (검색어와 정렬 조건 유지)
                    } else {
            %>			
                        <a href="searchForm.jsp?_keyword=<%=URLEncoder.encode(keyword,"UTF-8")%>&_pageNum=<%=i%>&_sort=<%=sort%>" class="page-num"><%= i %></a>
            <% 
                    }
                } 
            %>
        </div>
<%
    }
%>

</body>
</html>