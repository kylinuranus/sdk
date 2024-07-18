//
//  PickerViewController.m
//  Onstar
//
//  Created by Joshua on 5/27/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PickerViewController.h"
#import "CustomerInfo.h"
#import "PurchaseModel.h"

@interface PickerViewController ()

@end

@implementation PickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil     {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // DO other init
    }
    return self;
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    switch (_type) {
        case SelectionTypePayChannel:
            _dataList = [[PurchaseModel sharedInstance] payChannelArray];
//            _selectedIndex = 1;
            break;
        case SelectionTypeVechicle:
            _dataList = [[PurchaseModel sharedInstance] vehicleArray];
            _selectedIndex = 0;
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning     {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated     {
    [super viewDidAppear:animated];
    [_pickerView selectRow:_selectedIndex inComponent:0 animated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender     {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- picker view

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView     {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component     {
    return [_dataList count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component     {
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component     {
    return @"Test";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view     {
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    switch (_type) {
        case SelectionTypePayChannel:
        {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 30)];
            title.text = [_dataList objectAtIndex:row];
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor blackColor];
            [rowView addSubview:title];
        }
            break;
        case SelectionTypeVechicle:
        {
            NNVehicle *vehicle = [_dataList objectAtIndex:row];
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
            title.text = vehicle.makeModel;
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor blackColor];
            [rowView addSubview:title];
            
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 20)];
            description.text = vehicle.vin;
            description.textAlignment = NSTextAlignmentCenter;
            description.textColor = [UIColor blackColor];
            description.backgroundColor = [UIColor clearColor];
            
            [rowView addSubview:description];
        }
            break;
            
        default:
            break;
    }
    return rowView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component     {
    return;
}

#pragma mark -- toolbar
- (IBAction)cancelButtonClicked:(id)sender     {
    if (self.pickerDelegate) {
        [self.pickerDelegate pickerDidFinished:NO withSelectedIndex:-1];
    }
}

- (IBAction)doneButtonClicked:(id)sender     {
    NSInteger selectedRow = [_pickerView selectedRowInComponent:0];
    if (self.pickerDelegate) {
        _selectedIndex = selectedRow;
        [self.pickerDelegate pickerDidFinished:YES withSelectedIndex:selectedRow];
    }
}
@end
