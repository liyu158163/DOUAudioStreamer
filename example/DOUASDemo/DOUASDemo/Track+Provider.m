/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2016 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */

#import "Track+Provider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Track (Provider)

+ (void)load
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self remoteTracks];
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self musicLibraryTracks];
  });
}

+ (NSArray *)remoteTracks
{
  static NSArray *tracks = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://douban.fm/j/mine/playlist?type=n&channel=1004693&from=mainsite"]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:NULL
                                                     error:NULL];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];

    NSMutableArray *allTracks = [NSMutableArray array];
    for (NSDictionary *song in [dict objectForKey:@"song"]) {
      Track *track = [[Track alloc] init];
      [track setArtist:[song objectForKey:@"artist"]];
      [track setTitle:[song objectForKey:@"title"]];
      [track setAudioFileURL:[NSURL URLWithString:[song objectForKey:@"url"]]];
      [allTracks addObject:track];
    }

    tracks = [allTracks copy];
  });

  return tracks;
}

+ (NSArray *)musicLibraryTracks
{
  static NSArray *tracks = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      NSArray<NSString *> *paths = [[[NSBundle mainBundle] pathsForResourcesOfType:@"mp3" inDirectory:nil] sortedArrayUsingSelector:@selector(compare:)];


      NSMutableArray *allTracks = [NSMutableArray array];

      for (NSString *path in paths) {
          Track *track = [[Track alloc] init];
          track.artist = @"未知";
          track.title = [path componentsSeparatedByString:@"/"].lastObject;
          track.audioFileURL = [NSURL fileURLWithPath:path];
          [allTracks addObject:track];
      }
      Track *track = [[Track alloc] init];
      track.artist = @"未知";
      track.title = @"未知";
      track.audioFileURL = [NSURL URLWithString:@"http://audio01.dmhmusic.com/179_139_T10038844445_320_2_1_0_sdk-ts/0210/M00/10/A2/ChR461nwzd6AdTFoAJx9OFJjeb4031.mp3?xcode=78f7ee1ac0b52c2f43e02034242bd8658297000"];
      [allTracks addObject:track];
      tracks = [allTracks copy];

//    for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
//      if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
//        continue;
//      }
//
//      Track *track = [[Track alloc] init];
//      [track setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
//      [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
//      [track setAudioFileURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
//      [allTracks addObject:track];
//    }
//
//    for (NSUInteger i = 0; i < [allTracks count]; ++i) {
//      NSUInteger j = arc4random_uniform((u_int32_t)[allTracks count]);
//      [allTracks exchangeObjectAtIndex:i withObjectAtIndex:j];
//    }
//
//    tracks = [allTracks copy];
  });

  return tracks;
}

@end
