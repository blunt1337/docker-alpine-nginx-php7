<template>
	<div class="banner">
		<div class="effect">
			<img markup-inline src="../../assets/banner.svg" width="100%" height="100%"/>
		</div>
		<h1 menu-ignore>super alias your commands<br />in seconds.</h1>
		<a href="#getting-started" class="btn btn-outline-light">Get started</a>
	</div>
</template>

<style lang="scss">
@import "sass/variables";

.banner {
	width: 100%;
	height: 300px;
	overflow: hidden;
	position: relative;
	background: $primary;
	
	.effect {
		height: 100%;
		width: 100%;
		min-width: 300px;
		max-width: 500px;
		position: absolute;
		top: 0;
		right: 0;
		
		$color-top: $primary;
		$color-bot: #FFF;
		@for $i from 1 through 6 {
			path:nth-of-type(#{$i}) {
				fill: mix($color-top, $color-bot, ($i - 1) * 20%);
			}
		}
	}
	
	h1 {
		&:before {
			content: none;
		}
		position: absolute;
		left: 1em;
		top: 1em;
		color: $white;
	}
	a {
		position: absolute;
		left: 2em;
		bottom: 2em;
	}
}
</style>