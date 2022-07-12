<?php
/**
 * Plugin Name: Deploy WordPress to WP Engine - e2e Test
 * Plugin URI: https://github.com/wpengine/github-action-wpe-site-deploy
 * Description: Sample code to test the Site Deployment GitHub Action by WP Engine.
 * Version: 0.0.1
 */
 
 add_action('init', 'register_my_cpt');

 function register_my_cpt() {
    register_post_type('my-cpt', array(
        'public' => true
    ));
 }