/**
 * @format
 */

import React, { Component } from 'react';

import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button,
  NativeModules,
} from 'react-native';

import App from './App';
import { name as appName } from './app.json';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
});

class RNGiniBridge extends Component {

  constructor(props) {
    super(props);

    this.handleLaunchGini = this.handleLaunchGini.bind(this);
  }

  async handleLaunchGini() {
    const result = await NativeModules.GiniBridge.showGini();
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          GiniVision
        </Text>
        <Button
          title="Launch"
          onPress={this.handleLaunchGini}
        />
      </View>
    );
  }
}

AppRegistry.registerComponent('giniReactnative', () => RNGiniBridge);
