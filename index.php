<html>
<head>
	<title>Default index</title>
	<meta charset="utf-8">
	<style>
	body, html { padding:0; margin:0 }
	body {
		background:#333;
		background:-moz-linear-gradient(top,#a56aae 0%,#453fb3 100%);
		background:-webkit-linear-gradient(top,#a56aae 0%,#453fb3 100%);
		background:linear-gradient(to bottom,#a56aae 0%,#453fb3 100%);
		filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#a56aae',endColorstr='#453fb3',GradientType=0);
		
		text-align:center;
		color:#FFF;
		font-family:"Open Sans",sans-serif;
	}
	div {
		margin-top:50vh;
		transform:translateY(-50%);
	}
	</style>
</head>
<body>
	<div>
		<h1>I'm your default html page.<h1>
		<h2>You can override me in the folder "<?php echo __DIR__; ?>".</h2>
		<h3>PHP version <?php echo phpversion(); ?></h3>
	</div>
</body>
</html>